#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

static const uint64 base_time_quantum[MLFQ_LEVELS] __attribute__((unused)) = { 5, 10, 20, 40, 80 };

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S
extern uint ticks;
extern struct spinlock tickslock;

// System-wide scheduling metrics
struct {
  struct spinlock lock;
  uint total_processes_created;     // Total processes created
  uint total_processes_completed;   // Total processes that have finished
  uint total_context_switches;      // Total context switches across all processes
  uint total_cpu_time;              // Total CPU time used (sum of all runtimes)
  uint boot_time;                   // Time when system started
} metrics;


// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  initlock(&metrics.lock, "metrics");
  
  // Initialize global metrics
  metrics.total_processes_created = 0;
  metrics.total_processes_completed = 0;
  metrics.total_context_switches = 0;
  metrics.total_cpu_time = 0;
  metrics.boot_time = 0;  // Will be set to ticks at first use
  
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
  p->sleep_start_tick = 0;
  p->sleeping_for_io = 0;
  p->mlfq_level = -1;

  // Initialize MLFQ fields.
  p->priority = 0;
  p->time_slice_remaining = qm_get_time_quantum(0);
  p->cpu_time_used = 0;
  p->last_run_time = 0;
  p->wait_time = 0;
  p->io_count = 0;
  p->voluntary_yields = 0;
  p->cpu_usage_avg = 0;
  p->priority_boost_time = 0;
  p->mlfq_next = 0;
  p->mlfq_prev = 0;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  // Initialize scheduling metrics
  acquire(&tickslock);
  p->creation_time = ticks;
  if(metrics.boot_time == 0)
    metrics.boot_time = ticks;
  release(&tickslock);
  p->first_run_time = 0;
  p->finish_time = 0;
  p->last_run_time = 0;
  p->total_wait_time = 0;
  p->total_runtime = 0;
  p->context_switches = 0;
  
  // Update global process count
  acquire(&metrics.lock);
  metrics.total_processes_created++;
  release(&metrics.lock);

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  mlfq_remove(p);
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->io_count = 0;
  p->wait_time = 0;
  p->voluntary_yields = 0;
  p->sleep_start_tick = 0;
  p->sleeping_for_io = 0;
  p->mlfq_next = 0;
  p->mlfq_level = -1;
  p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  p->cwd = namei("/");

  p->state = RUNNABLE;
  mlfq_enqueue(p, p->priority);
  
  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if(sz + n > TRAPFRAME) {
      return -1;
    }
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
kfork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  mlfq_enqueue(np, np->priority);
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
kexit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  
  // Record finish time and update process completion count
  acquire(&tickslock);
  p->finish_time = ticks;
  release(&tickslock);
  
  acquire(&metrics.lock);
  metrics.total_processes_completed++;
  release(&metrics.lock);
  
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
kwait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU MLFQ scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - iterate priority levels from highest (0) to lowest (MLFQ_LEVELS-1).
//  - dequeue first runnable process from highest non-empty queue.
//  - set time quantum for the process's priority level.
//  - context switch to the selected process.
//  - on return, re-enqueue if the process is still runnable.
//  - if all queues are empty, wait for interrupt.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;
  for(;;){
    // The most recent process to run may have had interrupts
    // turned off; enable them to avoid a deadlock if all
    // processes are waiting. Then turn them back off
    // to avoid a possible race between an interrupt
    // and wfi.
    intr_on();
    intr_off();

    int found = 0;
    for(int lvl = 0; lvl < MLFQ_LEVELS && !found; lvl++){
      while((p = mlfq_dequeue(lvl)) != 0){
        acquire(&p->lock);
        if(p->state != RUNNABLE){
          release(&p->lock);
          continue;
        }
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.

        // Track scheduling metrics: record first run time and calculate wait time
        acquire(&tickslock);
        if(p->first_run_time == 0) {
          p->first_run_time = ticks;
          p->total_wait_time = ticks - p->creation_time;
        } else {
          // For subsequent runs, accumulate additional wait time since last context switch
          p->total_wait_time += ticks - p->creation_time;
        }
        p->last_run_time = ticks;
        release(&tickslock);

        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.

        // Track CPU time used
        acquire(&tickslock);
        uint runtime = ticks - p->last_run_time;
        if(runtime > 0) {
          p->total_runtime += runtime;
          acquire(&metrics.lock);
          metrics.total_cpu_time += runtime;
          release(&metrics.lock);
        }
        release(&tickslock);

        c->proc = 0;
        found = 1;
        release(&p->lock);
        break;
      }
    }
    if(found == 0) {
      // nothing to run; stop running on this core until an interrupt.
      asm volatile("wfi");
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched RUNNING");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;

  int voluntary = 1;
  if(p->state == RUNNABLE && p->time_slice_remaining == 0)
    voluntary = 0;
  qm_track_context_switch(voluntary);

  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->voluntary_yields++;
  p->state = RUNNABLE;
  mlfq_enqueue(p, p->priority);

  // Track context switch
  p->context_switches++;
  
  // Update global context switch counter
  acquire(&metrics.lock);
  metrics.total_context_switches++;
  release(&metrics.lock);
  
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();

  // Still holding p->lock from scheduler.
  release(&p->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);

    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    if (p->trapframe->a0 == -1) {
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
  uint64 satp = MAKE_SATP(p->pagetable);
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->io_count++;
  p->sleeping_for_io = 1;
  acquire(&tickslock);
  p->sleep_start_tick = ticks;
  release(&tickslock);
  p->state = SLEEPING;

  sched();

  // If wakeup() didn't account for this sleep interval (e.g., killed wakeup),
  // account for it here before clearing the sleep metadata.
  if(p->sleep_start_tick != 0){
    acquire(&tickslock);
    p->wait_time += (ticks - p->sleep_start_tick);
    release(&tickslock);
  }
  p->sleeping_for_io = 0;
  p->sleep_start_tick = 0;

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
  struct proc *p;
  // Safe without tickslock: uint read is atomic; may be called from
  // clockintr() which already holds tickslock.
  uint now = ticks;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        if(p->sleep_start_tick != 0)
          p->wait_time += (now - p->sleep_start_tick);
        p->sleep_start_tick = 0;
        p->sleeping_for_io = 0;

        // Boost priority after I/O-style sleep wakeup (reward interactive behavior).
        if(MLFQ_IO_WAKE_BOOST > 0){
          int np = p->priority - MLFQ_IO_WAKE_BOOST;
          p->priority = np < 0 ? 0 : np;
        }
        p->time_slice_remaining = qm_get_time_quantum(p->priority);
        p->priority_boost_time = now;

        p->state = RUNNABLE;
        mlfq_enqueue(p, p->priority);
        release(&p->lock);
      } else {
        release(&p->lock);
      }
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep() and enqueue in MLFQ.
        p->state = RUNNABLE;
        mlfq_enqueue(p, p->priority);
        release(&p->lock);
        return 0;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

// Get the average waiting time for a process
// Returns the average waiting time in ticks
uint
proc_avg_waiting_time(struct proc *p)
{
  if(p == 0)
    return 0;
  
  uint denom = p->context_switches + 1;
  if(denom == 0)
    denom = 1;
  return p->total_wait_time / denom;
}

// Get the response time for a process
// Returns the time in ticks from creation to first run
uint
proc_response_time(struct proc *p)
{
  if(p == 0 || p->first_run_time == 0)
    return 0;
  
  return p->first_run_time - p->creation_time;
}

// Get the context switch count for a process
// Returns the number of context switches
uint
proc_context_switches(struct proc *p)
{
  if(p == 0)
    return 0;
  
  return p->context_switches;
}

// Get the turnaround time for a process
// Returns the time from creation to finish (in ticks)
uint
proc_turnaround_time(struct proc *p)
{
  if(p == 0 || p->finish_time == 0)
    return 0;
  
  return p->finish_time - p->creation_time;
}

// Get elapsed system time since boot (in ticks)
uint
get_elapsed_time(void)
{
  uint elapsed;
  acquire(&tickslock);
  if(metrics.boot_time == 0)
    elapsed = 0;
  else
    elapsed = ticks - metrics.boot_time;
  release(&tickslock);
  return elapsed;
}

// Get context switches per second
uint
proc_context_switches_per_second(void)
{
  uint elapsed = get_elapsed_time();
  if(elapsed == 0)
    return 0;
  // Note: xv6 runs at ~10 million ticks per second in simulation
  // Return as (switches * 1000000) / elapsed for more precision
  acquire(&metrics.lock);
  uint total_switches = metrics.total_context_switches;
  release(&metrics.lock);
  
  // Avoid division by zero and return ticks-per-second basis
  return total_switches;
}

// Get CPU utilization percentage (0-100)
uint
proc_cpu_utilization(void)
{
  uint elapsed = get_elapsed_time();
  if(elapsed == 0)
    return 0;
  
  acquire(&metrics.lock);
  uint total_cpu = metrics.total_cpu_time;
  release(&metrics.lock);
  
  // Return utilization as percentage (cpu_time * 100 / elapsed_time)
  if(total_cpu == 0)
    return 0;
  return (total_cpu * 100) / elapsed;
}

// Get throughput (processes per second)
uint
proc_throughput(void)
{
  uint elapsed = get_elapsed_time();
  if(elapsed == 0)
    return 0;
  
  acquire(&metrics.lock);
  uint completed = metrics.total_processes_completed;
  release(&metrics.lock);
  
  return completed;
}

// Print scheduling metrics for all processes
void
proc_print_metrics(void)
{
  struct proc *p;
  
  printf("\nProcess Scheduling Metrics:\n");
  printf("PID\tName\t\tAvg Wait\tResponse\tContext Switches\n");
  printf("---\t----\t\t--------\t--------\t-------- --------\n");
  
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    
    acquire(&p->lock);
    printf("%d\t%s\t\t%d\t\t%d\t\t%d\n",
           p->pid,
           p->name,
           proc_avg_waiting_time(p),
           proc_response_time(p),
           proc_context_switches(p));
    release(&p->lock);
  }
  printf("\n");
}

// Print extended metrics including turnaround time and system-wide stats
void
proc_print_extended_metrics(void)
{
  struct proc *p;
  
  printf("\n=== Extended Process Scheduling Metrics ===\n");
  printf("PID\tName\t\tTurnaround\tAvg Wait\tResponse\tCtx Switches\n");
  printf("---\t----\t\t----------\t--------\t--------\t---------- -\n");
  
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    
    acquire(&p->lock);
    printf("%d\t%s\t\t%d\t\t%d\t\t%d\t\t%d\n",
           p->pid,
           p->name,
           proc_turnaround_time(p),
           proc_avg_waiting_time(p),
           proc_response_time(p),
           proc_context_switches(p));
    release(&p->lock);
  }
  
  // System-wide metrics
  uint elapsed = get_elapsed_time();
  printf("\n=== System-Wide Metrics ===\n");
  printf("Elapsed Time (ticks): %d\n", elapsed);
  acquire(&metrics.lock);
  printf("Total Processes Created: %d\n", metrics.total_processes_created);
  printf("Total Processes Completed: %d\n", metrics.total_processes_completed);
  printf("Total Context Switches: %d\n", metrics.total_context_switches);
  printf("Total CPU Time (ticks): %d\n", metrics.total_cpu_time);
  release(&metrics.lock);
  
  if(elapsed > 0) {
    uint util = proc_cpu_utilization();
    printf("CPU Utilization: %d%%\n", util);
    printf("Throughput: %d processes completed\n", proc_throughput());
    printf("Context Switches (total): %d\n", proc_context_switches_per_second());
  }
  printf("\n");
}

// Print process metrics in CSV format
// Format: pid,name,state,creation_time,first_run_time,finish_time,turnaround_time,response_time,avg_wait,context_switches,total_runtime
void
proc_print_csv_header(void)
{
  printf("pid,name,state,creation_time,first_run_time,finish_time,turnaround_time,response_time,avg_wait,context_switches,total_runtime\n");
}

void
proc_print_csv_data(void)
{
  struct proc *p;
  char *states[] = {
    [UNUSED]    "unused",
    [USED]      "used",
    [SLEEPING]  "sleeping",
    [RUNNABLE]  "runnable",
    [RUNNING]   "running",
    [ZOMBIE]    "zombie"
  };
  
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    
    acquire(&p->lock);
    
    char *state = "unknown";
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    
    uint turnaround = proc_turnaround_time(p);
    uint response = proc_response_time(p);
    uint avg_wait = proc_avg_waiting_time(p);
    
    printf("%d,%s,%s,%d,%d,%d,%d,%d,%d,%d,%d\n",
           p->pid,
           p->name,
           state,
           p->creation_time,
           p->first_run_time,
           p->finish_time,
           turnaround,
           response,
           avg_wait,
           p->context_switches,
           p->total_runtime);
    
    release(&p->lock);
  }
}

// Print system-wide metrics in CSV format
void
proc_print_system_csv(void)
{
  uint elapsed = get_elapsed_time();
  
  printf("timestamp,metric,value,unit\n");
  
  acquire(&tickslock);
  printf("%d,boot_time,%d,ticks\n", ticks, metrics.boot_time);
  printf("%d,elapsed_time,%d,ticks\n", ticks, elapsed);
  release(&tickslock);
  
  acquire(&metrics.lock);
  printf("%d,total_processes_created,%d,count\n", ticks, metrics.total_processes_created);
  printf("%d,total_processes_completed,%d,count\n", ticks, metrics.total_processes_completed);
  printf("%d,total_context_switches,%d,count\n", ticks, metrics.total_context_switches);
  printf("%d,total_cpu_time,%d,ticks\n", ticks, metrics.total_cpu_time);
  release(&metrics.lock);
  
  if(elapsed > 0) {
    uint util = proc_cpu_utilization();
    printf("%d,cpu_utilization,%d,percent\n", ticks, util);
    printf("%d,throughput,%d,count\n", ticks, proc_throughput());
  }
  printf("\n");
}
