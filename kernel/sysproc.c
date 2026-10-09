#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"


uint64 sys_interpose(void);

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
    sleep_prepare(&ticks);
    release(&tickslock);
    sleep();
    acquire(&tickslock);
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
sys_sleep(void)
{
  int n;
  uint ticks0;

  // 1. Get the requested number of ticks from user space
  argint(0, &n);

  // 2. Acquire the tick lock to safely inspect global ticks
  acquire(&tickslock);
  ticks0 = ticks;
  
  // 3. Loop until the required ticks have passed
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    
    // Use the new modern xv6 sleep pattern:
    // a. Prepare to sleep on the &ticks channel
    sleep_prepare(&ticks);
    
    // b. Release the lock before sleeping (as required by sleep_prepare pattern)
    release(&tickslock);
    
    // c. Call the parameterless sleep function you found
    sleep();
    
    // d. Re-acquire the tick lock to check the loop condition again safely
    acquire(&tickslock);
  }
  
  release(&tickslock);
  return 0;
}


uint64 sys_interpose(void) {
  int mask;
  char path[MAXPATH];

  argint(0, &mask);
  argstr(1, path, MAXPATH);

  struct proc* p = myproc();

  p->interpose_mask = mask;
  strncpy(p->interpose_allowed_path, path, MAXPATH);

  return 0;
}