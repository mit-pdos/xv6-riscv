#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "powerstate.h"

extern struct proc proc[];

struct energystat_row {
  int pid;
  int state;
  int energy_used;
  int energy_budget;
  int estimated_burst;
  int power_state;
  char name[16];
};

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

// Feature 4: Halt-on-Idle statistics syscall.
// Copies per-CPU idle stats to the user-space buffer.
// arg0: pointer to user buffer (struct idleinfo[NCPU])
// arg1: number of CPUs to report (capped at NCPU)
// Returns 0 on success, -1 on error.
//
// struct idleinfo layout (defined in user code):
//   uint64 idle_ticks;
//   uint64 total_ticks;
//   uint64 wfi_count;
uint64
sys_idlestat(void)
{
  uint64 uaddr;
  int ncpus;

  argaddr(0, &uaddr);
  argint(1, &ncpus);

  if(ncpus <= 0 || ncpus > NCPU)
    ncpus = NCPU;

  uint64 idle[NCPU];
  uint64 total[NCPU];
  uint64 wfi_counts[NCPU];

  get_idle_ticks(idle, total, wfi_counts);

  // Copy per-CPU stats to user space as an array of 3 uint64s per CPU
  // Layout: [idle_ticks, total_ticks, wfi_count] × ncpus
  struct proc *p = myproc();
  for(int i = 0; i < ncpus; i++){
    uint64 buf[3];
    buf[0] = idle[i];
    buf[1] = total[i];
    buf[2] = wfi_counts[i];
    if(copyout(p->pagetable, uaddr + i * sizeof(buf), (char*)buf, sizeof(buf)) < 0)
      return -1;
  }

  return 0;
}

// Set the name of the calling process (visible in energytop/energystat).
// arg0: pointer to null-terminated name string (max 15 chars + NUL).
// Returns 0 on success, -1 on error.
uint64
sys_setprocname(void)
{
  char name[16];
  if(argstr(0, name, sizeof(name)) < 0)
    return -1;
  struct proc *p = myproc();
  acquire(&p->lock);
  safestrcpy(p->name, name, sizeof(p->name));
  release(&p->lock);
  return 0;
}

// Feature 3/5: expose per-process energy budgeting metrics to user space.
// arg0: pointer to user buffer (array of struct energystat_row)
// arg1: max number of rows to copy (capped at NPROC)
// Returns number of rows copied, or -1 on error.
uint64
sys_energystat(void)
{
  uint64 uaddr;
  int maxrows;
  int copied = 0;
  struct proc *cur = myproc();

  argaddr(0, &uaddr);
  argint(1, &maxrows);

  if(maxrows <= 0 || maxrows > NPROC)
    maxrows = NPROC;

  // Force a live count before reading current_power_state, so the
  // snapshot always reflects the actual runnable process count right now
  // rather than waiting for the next 8-tick timer interrupt sample.
  update_power_state();

  for(struct proc *p = proc; p < &proc[NPROC] && copied < maxrows; p++){
    struct energystat_row row;

    acquire(&p->lock);
    if(p->state == UNUSED){
      release(&p->lock);
      continue;
    }

    proc_energy_refresh(p, ticks);
    row.pid = p->pid;
    row.state = p->state;
    row.energy_used = p->energy_used;
    row.energy_budget = p->energy_budget;
    row.estimated_burst = p->estimatedBurstTime;
    row.power_state = (int)current_power_state;
    safestrcpy(row.name, p->name, sizeof(row.name));
    release(&p->lock);

    if(copyout(cur->pagetable,
               uaddr + copied * sizeof(struct energystat_row),
               (char*)&row,
               sizeof(struct energystat_row)) < 0)
      return -1;

    copied++;
  }

  return copied;
}
