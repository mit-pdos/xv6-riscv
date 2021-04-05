#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "fs.h"


uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0){
    return -1;
  }

  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  int res = myproc()->pid;
  return res;
}

uint64
sys_fork(void)
{
  int res = fork();
  return res;
}

uint64
sys_wait_stat(void)
{
  uint64 p;
  uint64 performance;

  if(argaddr(0, &p) < 0 ||
     argaddr(1, &performance) < 0){
    return -1;
  }

  int res = wait_stat(p, (struct perf*)performance);
  return res;
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0){
    return -1;
  }
  int res = wait(p);
  return res;
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0){
    return -1;
  }
    
  addr = myproc()->sz;
  if(growproc(n) < 0){
    return -1;
  }
  
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0){
    return -1;
  }
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
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
  if(argint(0, &pid) < 0){
    return -1;
  }
  int res =  kill(pid);
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
  return xticks;
}


uint64
sys_trace(void)
{
  int mask; 
  int pid;

  if(argint(0, &mask) < 0 || argint(1, &pid)){
    return -1;
  }
  
  trace(mask,pid);
  return 0;
}

