#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "stat.h"
#include "spinlock.h"
#include "fs.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);
static void free_hib_pages(struct proc *p);
static void free_hib_storage(struct proc *p);
static int restore_hib_pages(struct proc *p);
static int hibernate_pages(struct proc *p);

extern char trampoline[]; // trampoline.S

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

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  free_hib_pages(p);
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
  p->suspend_pending = 0;
  p->hibernated = 0;
  p->hibernating = 0;
  p->xstate = 0;
  p->hib_pages = 0;
  p->hib_inode = 0;
  p->state = UNUSED;
}

static void
free_hib_pages(struct proc *p)
{
  struct hib_page *hp = p->hib_pages;
  while(hp){
    struct hib_page *next = hp->next;
    kfree((void*)hp);
    hp = next;
  }
  p->hib_pages = 0;
}

static int
restore_hib_pages(struct proc *p)
{
  struct hib_page *hp;
  char *mem;
  int n;

  if(p->hib_inode == 0)
    return -1;

  for(hp = p->hib_pages; hp; hp = hp->next){
    for(int i = 0; i < hp->used; i++){
      mem = kalloc();
      if(mem == 0)
        return -1;
      begin_op();
      ilock(p->hib_inode);
      n = readi(p->hib_inode, 0, (uint64)mem, hp->ents[i].off, PGSIZE);
      iunlock(p->hib_inode);
      end_op();
      if(n != PGSIZE){
        kfree(mem);
        return -1;
      }
      if(mappages(p->pagetable, hp->ents[i].va, PGSIZE,
                  (uint64)mem, hp->ents[i].flags) < 0){
        kfree(mem);
        return -1;
      }
    }
  }
  sfence_vma();
  free_hib_storage(p);
  return 0;
}

static void
free_hib_storage(struct proc *p)
{
  struct inode *ip = p->hib_inode;

  if(ip){
    begin_op();
    ilock(ip);
    itrunc(ip);
    iupdate(ip);
    iunlock(ip);
    iput(ip);
    end_op();
  }

  p->hib_inode = 0;
  free_hib_pages(p);
  p->hibernated = 0;
}

static int
hibernate_pages(struct proc *p)
{
  uint64 va, sz, off = 0;
  pte_t *pte;
  struct hib_page *head = 0, *tail = 0, *cur = 0;
  struct inode *ip = 0;
  int n;

  begin_op();
  ip = ialloc(ROOTDEV, T_FILE);
  end_op();
  if(ip == 0)
    return -1;

  sz = PGROUNDUP(p->sz);
  for(va = 0; va < sz; va += PGSIZE){
    pte = walk(p->pagetable, va, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
      continue;

    if(cur == 0 || cur->used >= NELEM(cur->ents)){
      struct hib_page *newp = (struct hib_page *)kalloc();
      if(newp == 0)
        goto rollback;
      memset(newp, 0, PGSIZE);
      if(head == 0)
        head = newp;
      else
        tail->next = newp;
      tail = newp;
      cur = newp;
    }

    begin_op();
    ilock(ip);
    n = writei(ip, 0, PTE2PA(*pte), off, PGSIZE);
    iunlock(ip);
    end_op();
    if(n != PGSIZE)
      goto rollback;

    cur->ents[cur->used].va = va;
    cur->ents[cur->used].flags = PTE_FLAGS(*pte) & ~PTE_V;
    cur->ents[cur->used].off = off;
    cur->used++;
    off += PGSIZE;

    uvmunmap(p->pagetable, va, 1, 1);
  }

  sfence_vma();
  p->hib_pages = head;
  p->hib_inode = ip;
  p->hibernated = 1;
  return 0;

rollback:
  for(struct hib_page *hp = head; hp; hp = hp->next){
    for(int i = 0; i < hp->used; i++){
      char *mem = kalloc();
      if(mem == 0)
        continue;
      begin_op();
      ilock(ip);
      n = readi(ip, 0, (uint64)mem, hp->ents[i].off, PGSIZE);
      iunlock(ip);
      end_op();
      if(n != PGSIZE){
        kfree(mem);
        continue;
      }
      mappages(p->pagetable, hp->ents[i].va, PGSIZE, (uint64)mem, hp->ents[i].flags);
    }
  }
  sfence_vma();

  begin_op();
  ilock(ip);
  itrunc(ip);
  iupdate(ip);
  iunlock(ip);
  iput(ip);
  end_op();

  while(head){
    struct hib_page *next = head->next;
    kfree((void*)head);
    head = next;
  }
  return -1;
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

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
static void
cpu_idle_halt(void)
{
  struct cpu *c = mycpu();

  acquire(&tickslock);
  c->idle_halt_count++;
  c->idle_start_ticks = ticks;
  release(&tickslock);

  intr_on();
  asm volatile("wfi");

  acquire(&tickslock);
  c->idle_ticks_total += ticks - c->idle_start_ticks;
  release(&tickslock);
}
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
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
        found = 1;
      }
      release(&p->lock);
    }
    if(found == 0) {
  // nothing to run; stop running on this core until an interrupt.
  cpu_idle_halt();
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
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  if(p->suspend_pending){
    p->state = SUSPENDED;
    p->suspend_pending = 0;
  } else {
    p->state = RUNNABLE;
  }
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
  p->state = SLEEPING;

  sched();

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

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        if(p->suspend_pending){
          p->state = SUSPENDED;
          p->suspend_pending = 0;
        } else {
          p->state = RUNNABLE;
        }
      }
      release(&p->lock);
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
      if(p->hibernating){
        release(&p->lock);
        return 0;
      }
      if(p->state == SLEEPING){
        p->state = RUNNABLE;
        p->suspend_pending = 0;
        release(&p->lock);
        return 0;
      }
      if(p->state == SUSPENDED && p->hibernated){
        p->hibernating = 1;
        release(&p->lock);
        if(restore_hib_pages(p) < 0){
          acquire(&p->lock);
          p->hibernating = 0;
          release(&p->lock);
          return -1;
        }
        acquire(&p->lock);
        p->hibernating = 0;
        if(p->state == SUSPENDED){
          p->state = RUNNABLE;
          p->suspend_pending = 0;
        }
        release(&p->lock);
        return 0;
      }
      if(p->state == SUSPENDED){
        p->state = RUNNABLE;
        p->suspend_pending = 0;
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
ksuspend(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      if(p->state == UNUSED || p->state == ZOMBIE){
        release(&p->lock);
        return -1;
      }
      if(p->state == SUSPENDED || p->suspend_pending){
        release(&p->lock);
        return 0;
      }
      if(p->state == RUNNABLE){
        p->state = SUSPENDED;
        release(&p->lock);
        return 0;
      }
      // For RUNNING and SLEEPING, delay transition until deschedule/wakeup.
      p->suspend_pending = 1;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

int
kresume(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      if(p->hibernating){
        release(&p->lock);
        return -1;
      }
      if(p->state == SUSPENDED){
        if(p->hibernated){
          p->hibernating = 1;
          release(&p->lock);
          if(restore_hib_pages(p) < 0){
            acquire(&p->lock);
            p->hibernating = 0;
            release(&p->lock);
            return -1;
          }
          acquire(&p->lock);
          p->hibernating = 0;
          if(p->state != SUSPENDED){
            release(&p->lock);
            return -1;
          }
        }
        p->suspend_pending = 0;
        p->state = RUNNABLE;
        release(&p->lock);
        return 0;
      }
      if(p->suspend_pending){
        p->suspend_pending = 0;
        release(&p->lock);
        return 0;
      }
      release(&p->lock);
      return -1;
    }
    release(&p->lock);
  }
  return -1;
}

int
khibernate(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid != pid){
      release(&p->lock);
      continue;
    }

    if(p->state != SUSPENDED || p->hibernated || p->hibernating){
      release(&p->lock);
      return -1;
    }
    p->hibernating = 1;
    release(&p->lock);

    int rv = hibernate_pages(p);
    acquire(&p->lock);
    p->hibernating = 0;
    if(rv < 0){
      release(&p->lock);
      return -1;
    }
    if(p->state != SUSPENDED){
      release(&p->lock);
      return -1;
    }
    release(&p->lock);
    return 0;
  }

  return -1;
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
  [SUSPENDED] "suspend",
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
void
print_idle_stats(void)
{
  struct cpu *c;

  printf("\nCPU idle halt statistics:\n");
  for(c = cpus; c < &cpus[NCPU]; c++){
    printf("cpu %d: halt_count=%lu idle_ticks=%lu\n",
           (int)(c - cpus),
           c->idle_halt_count,
           c->idle_ticks_total);
  }
}

int
getprocs(uint64 addr, int nmax)
{
  struct proc *p;
  struct pinfo pi;
  int count = 0;

  for(p = proc; p < &proc[NPROC] && count < nmax; p++){
    acquire(&p->lock);
    if(p->state != UNUSED){
      pi.pid = p->pid;
      pi.state = p->state;
      pi.hibernated = p->hibernated;
      pi.hibernating = p->hibernating;
      pi.sz = p->sz;
      pi.ticks = p->ticks_total;
      strncpy(pi.name, p->name, PNAMESIZE);
      release(&p->lock);

      if(copyout(myproc()->pagetable, addr + count * sizeof(pi),
                 (char *)&pi, sizeof(pi)) < 0)
        return -1;
      count++;
    } else {
      release(&p->lock);
    }
  }
  return count;
}
