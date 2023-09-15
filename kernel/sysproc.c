#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

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

//retrieve the trace syscall argument from user mode into kernal mode int mask
uint64
sys_trace(){
  int mask=0;
  if(argint(0, &mask) < 0) return -1;
  myproc() -> mask = mask;
  return 0;
}

uint64
sys_info(){
  uint64 freeMem, procNum, addr; //address of sysinfo in user space
  struct proc *p = myproc();  

  if (argaddr(0, &addr) < 0 ) return -1; //get the argument(an address pointing to a instance of sysinfo struct) of the sysinfo function call from user mode and store into the address into varaible addr

  freeMem = countFreeMemory();
  procNum = countProcs();

  if(copyout(p->pagetable, addr, (char *)&freeMem, sizeof(freeMem)) < 0 ||
    copyout(p->pagetable, addr + sizeof(freeMem), (char *)&procNum, sizeof(procNum)) < 0 )
     return -1;
   return 0;
}
