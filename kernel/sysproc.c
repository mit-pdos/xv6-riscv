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
  
  // Local struct matching user-visible struct proc_info
  struct {
    int pid;
    int parent_pid;
    int state;
    int killed;
    int xstate;
    uint64 sz;
    uint64 kstack;
    uint64 pagetable;
    uint64 trapframe;
    uint64 context_sp;
    uint64 ofile[16];
    uint64 cwd;
    char name[16];
    uint64 chan;
  } info;
  
  struct proc *p;
  int found = 0;
  
  // Lock required when accessing process table
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->pid == pid) {
      // Populate the user-visible info struct
      info.pid = p->pid;
      info.parent_pid = p->parent ? p->parent->pid : 0;
      info.state = p->state;
      info.killed = p->killed;
      info.xstate = p->xstate;
      info.sz = p->sz;
      info.kstack = p->kstack;
      info.pagetable = (uint64)p->pagetable;
      info.trapframe = (uint64)p->trapframe;
      // context contains saved registers; copy the stack pointer value
      info.context_sp = p->context.sp;
      // Copy open file pointers as uint64s
      for(int i = 0; i < 16; i++) {
        info.ofile[i] = (uint64)p->ofile[i];
      }
      info.cwd = (uint64)p->cwd;
      memmove(info.name, p->name, sizeof(info.name));
      info.chan = (uint64)p->chan;

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
