#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "logger.h"
uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
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
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  if (myproc()->current_thread) { 
     release(&tickslock); 
     sleepthread(n, ticks0); 
     return 0; 
 } 
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
  return kill(pid);
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
sys_trigger(void)
{
    log_message(LOG_INFO, "This is a log to test a new xv6 system call");
    return 0;
}
uint64 sys_thread(void) { 
    uint64 start_thread, stack_address, arg; 
    argaddr(0, &start_thread); 
    argaddr(1, &stack_address); 
    argaddr(2, &arg); 
    struct thread *t = allocthread(start_thread, stack_address, arg); 
    return t ? t->id : 0; 
}
uint64 sys_jointhread(void) { 
    int id; 
    argint(0, &id); 
    return jointhread(id); 
}
uint64
sys_gettid(void) {
  struct proc *p = myproc();
  struct thread *t = p->current_thread;
  return t ? t->id : p->pid;
}