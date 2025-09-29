#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

extern struct proc proc[NPROC];  // Array of processes

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

// Get process information for a specific process
uint64
sys_getprocinfo(void)
{
  int pid;
  uint64 info_ptr;
  
  // Get arguments from user space
  argint(0, &pid);       // Get the pid argument
  argaddr(1, &info_ptr); // Get the pointer to user struct
  
  // Local struct to store info before copying to user space
  struct {
    int pid;
    int state;
    uint64 sz;
    uint64 kstack;
    char name[16];
  } info;
  
  struct proc *p;
  int found = 0;
  
  // Lock required when accessing process table
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->pid == pid) {
      // Copy the process information to our local struct
      info.pid = p->pid;
      info.state = p->state;
      info.sz = p->sz;
      info.kstack = p->kstack;
      memmove(info.name, p->name, sizeof(info.name));
      
      found = 1;
      release(&p->lock);
      break;
    }
    release(&p->lock);
  }
  
  if(found) {
    // Copy the info to user space
    if(copyout(myproc()->pagetable, info_ptr, (char*)&info, sizeof(info)) < 0)
      return -1;
    return 0;
  } else {
    return -1; // Process not found
  }
}
