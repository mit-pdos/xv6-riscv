#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"


uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0){
    isProcUnderTrace(myproc()->pid, -2, "exit", -1, myproc()->mask, (1<< SYS_exit));
    return -1;
  }

  isProcUnderTrace(myproc()->pid, -2, "exit", 0, myproc()->mask, (1<< SYS_exit));  
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  int res = myproc()->pid;
  isProcUnderTrace(myproc()->pid, -2, "getpid", res, myproc()->mask, (1<< 11) );  
  return res;
}

uint64
sys_fork(void)
{
  int res = fork();
  isProcUnderTrace(myproc()->pid, -2, "fork", res, myproc()->mask, (1<< 1));
  return res;
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0){
    isProcUnderTrace(myproc()->pid, -2, "wait", -1, myproc()->mask, (1<< 3));
    return -1;
  }
  int res = wait(p);
  isProcUnderTrace(myproc()->pid, -2, "wait", res, myproc()->mask, (1<< 3));
  return res;
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;
  struct proc *p = myproc();

  if(argint(0, &n) < 0){
    isProcUnderTrace(p->pid, n, "sbrk", -1, p->mask, (1<< 12));
    return -1;
  }
    
  addr = myproc()->sz;
  if(growproc(n) < 0){
    isProcUnderTrace(p->pid, n, "sbrk", -1, p->mask, (1<< 12));
    return -1;
  }
  
  isProcUnderTrace(p->pid, n, "sbrk", addr, p->mask, (1<< 12));
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0){
    isProcUnderTrace(myproc()->pid, -2, "sleep", -1, myproc()->mask, (1<< 13));
    return -1;
  }
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      isProcUnderTrace(myproc()->pid, -2, "sleep", -1, myproc()->mask, (1<< 13));
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  isProcUnderTrace(myproc()->pid, -2, "sleep", 0, myproc()->mask, (1<< 13));
  return 0;
}

uint64
sys_kill(void)
{
  int pid;
  struct proc *p = myproc();

  if(argint(0, &pid) < 0){
    isProcUnderTrace(p->pid, pid, "kill" , -1, p->mask, (1<< 6));
    return -1;
  }
  int res =  kill(pid);
  isProcUnderTrace(p->pid, pid, "kill" , res, p->mask, (1<< 6));
  return res;
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
  isProcUnderTrace(myproc()->pid, -2, "uptime" , xticks, myproc()->mask, (1<< 14));
  return xticks;
}


uint64
sys_trace(void)
{
  int mask; 
  int pid;

  if(argint(0, &mask) < 0 || argint(1, &pid)){
    isProcUnderTrace(myproc()->pid, -2, "trace" , -1, myproc()->mask, (1<< 22));
    return -1;
  }
  
  trace(mask,pid);
  isProcUnderTrace(myproc()->pid, -2, "trace" , 0, myproc()->mask, (1<<22));
  return 0;
}

