#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "../user/pstat.h"

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

// MY FUNCTION FOR SYS_GETPINFO()
// Copies information about all processes into a user-provided pstat structure.
uint
sys_getpinfo(void)
{
  uint64 addr;              // User-space address where struct pstat will be copied
  struct pstat ps;          // Kernel-local pstat structure to be filled
  struct proc *p;

  // Fetch the user pointer (argument 0) from the system call arguments
  argaddr(0, &addr);

  // Iterate over the entire process table
  for(int i = 0; i < NPROC; i++){
    p = &proc[i];

    // Acquire the process lock to safely read its fields
    acquire(&p->lock);

    // Copy per-process information into the corresponding pstat arrays
    ps.pid[i]      = p->pid;                            // Process ID
    ps.ppid[i]     = p->parent ? p->parent->pid : 0;    // Parent PID (0 if no parent)
    ps.priority[i] = p->priority;                       // MLFQ priority level
    ps.state[i]    = p->state;                          // Current process state
    ps.size[i]     = p->sz;                             // Memory size in bytes
    safestrcpy(ps.name[i], p->name, 16);                // Process name

    // Release the process lock before moving to the next entry
    release(&p->lock);
  }

  // Copy the filled pstat structure from kernel space to user space
  // Return -1 on failure
  if(copyout(myproc()->pagetable, addr, (char *)&ps, sizeof(ps)) < 0)
    return -1;

  // Success
  return 0;
}

