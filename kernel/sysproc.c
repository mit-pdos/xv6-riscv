#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "procstat.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_getcsstats(void)
{
  uint64 a0, a1, a2, a3;
  uint64 total, vol, invol;
  uint64 rate_x1000;
  struct proc *p = myproc();

  argaddr(0, &a0);
  argaddr(1, &a1);
  argaddr(2, &a2);
  argaddr(3, &a3);

  qm_get_context_switch_counts(&total, &vol, &invol);
  rate_x1000 = (uint64)qm_get_context_switch_rate_x1000();

  if(copyout(p->pagetable, a0, (char *)&total, sizeof(total)) < 0)
    return -1;
  if(copyout(p->pagetable, a1, (char *)&vol, sizeof(vol)) < 0)
    return -1;
  if(copyout(p->pagetable, a2, (char *)&invol, sizeof(invol)) < 0)
    return -1;
  if(copyout(p->pagetable, a3, (char *)&rate_x1000, sizeof(rate_x1000)) < 0)
    return -1;
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Copy current process I/O scheduling counters to user pointers.
uint64
sys_getschedstats(void)
{
  uint64 a0, a1, a2;
  struct proc *p = myproc();
  uint64 io, wt, vy;

  argaddr(0, &a0);
  argaddr(1, &a1);
  argaddr(2, &a2);

  acquire(&p->lock);
  io = p->io_count;
  wt = p->wait_time;
  vy = p->voluntary_yields;
  release(&p->lock);

  if(copyout(p->pagetable, a0, (char *)&io, sizeof(io)) < 0)
    return -1;
  if(copyout(p->pagetable, a1, (char *)&wt, sizeof(wt)) < 0)
    return -1;
  if(copyout(p->pagetable, a2, (char *)&vy, sizeof(vy)) < 0)
    return -1;
  return 0;
}

uint64
sys_yield(void)
{
  yield();
  return 0;
}

uint64
sys_getload(void)
{
  uint64 a0, a1;
  uint64 load;
  uint64 avg_x1000;
  struct proc *p = myproc();

  argaddr(0, &a0);
  argaddr(1, &a1);

  load = (uint64)qm_get_system_load();
  avg_x1000 = (uint64)qm_get_loadavg_x1000();

  if(copyout(p->pagetable, a0, (char *)&load, sizeof(load)) < 0)
    return -1;
  if(copyout(p->pagetable, a1, (char *)&avg_x1000, sizeof(avg_x1000)) < 0)
    return -1;
  return 0;
}
// Fill *st with a snapshot of process statistics for the given pid.
// If pid < 0, uses the calling process.
// Returns 0 on success, -1 if pid not found.
uint64
sys_getprocstat(void)
{
  int pid;
  uint64 addr;
  struct proc *caller = myproc();

  argint(0, &pid);
  argaddr(1, &addr);

  // Resolve target process.
  struct proc *target = 0;
  if(pid < 0){
    target = caller;
  } else {
    for(struct proc *p = proc; p < &proc[NPROC]; p++){
      acquire(&p->lock);
      if(p->state != UNUSED && p->pid == pid){
        target = p;
        // Keep lock held across snapshot — released below.
        break;
      }
      release(&p->lock);
    }
    if(target == 0)
      return -1;
  }

  // Take a locked snapshot of the fields we need.
  if(target != caller)
    ; // lock already held from the search loop above
  else
    acquire(&target->lock);

  struct procstat st;
  st.pid            = target->pid;
  safestrcpy(st.name, target->name, sizeof(st.name));
  st.state          = (int)target->state;
  st.priority       = target->priority;
  st.behavior_type  = target->behavior_type;
  st.creation_time  = target->creation_time;
  st.first_run_time = target->first_run_time;
  st.finish_time    = target->finish_time;
  st.response_time  = (target->first_run_time > 0)
                        ? target->first_run_time - target->creation_time : 0;
  st.turnaround_time = (target->finish_time > 0)
                        ? target->finish_time - target->creation_time
                        : (ticks > target->creation_time ? ticks - target->creation_time : 0);
  st.total_wait_time   = target->total_wait_time;
  st.total_runtime     = target->total_runtime;
  st.context_switches  = target->context_switches;
  st.io_count          = target->io_count;
  st.voluntary_yields  = target->voluntary_yields;

  release(&target->lock);

  if(copyout(caller->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    return -1;
  return 0;
}

// Fill *st with a snapshot of system-wide scheduling statistics.
uint64
sys_getsysstats(void)
{
  uint64 addr;
  struct proc *caller = myproc();

  argaddr(0, &addr);

  struct sysstats st;
  proc_fill_sysstats(&st);

  if(copyout(caller->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    return -1;
  return 0;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);

  acquire(&tickslock);
  ticks0 = ticks;

  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }

  release(&tickslock);
  return 0;
}
