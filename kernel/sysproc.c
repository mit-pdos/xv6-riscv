#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "pinfo.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
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

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
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
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
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

uint64
sys_getpinfo(void)
{
  uint64 addr;
  struct proc *p;
  struct proc *mp = myproc();
  struct pinfo info;
  int i;

  argaddr(0, &addr);
  memset(&info, 0, sizeof(info));

  for (i = 0, p = proc; p < &proc[NPROC]; p++, i++) {
    acquire(&p->lock);
    if (p->state != UNUSED) {
      info.inuse[i] = 1;
      info.pid[i] = p->pid;
      info.owner[i] = p->owner;
      info.priority[i] = p->priority;
      info.status[i] = p->state;
      info.tickets[i] = p->tickets;
      info.runtime[i] = p->runtime;
      safestrcpy(info.name[i], p->name, sizeof(info.name[i]));
    }
    release(&p->lock);
  }

  if (copyout(mp->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    return -1;
  return 0;
}

uint64
sys_setpriority(void)
{
  int pid;
  int priority;

  argint(0, &pid);
  argint(1, &priority);

  return ksetpriority(pid, priority);
}

uint64
sys_settickets(void)
{
  int pid;
  int number;

  argint(0, &pid);
  argint(1, &number);

  return ksettickets(pid, number);
}
