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
uint64 sys_hello(void) //hello syscall definition
{
int n;
argint (0, &n);
print_hello(n);
return 0;
}

// Global variable to count system calls
extern uint64 sys_call_count;
extern uint64 count_free_pages(); // Declare the function


// Lab 1 sysinfo
uint64 sys_sysinfo(void) {
    int param;
    uint64 result = 0;

    // Fetch the first argument using argint
    argint(0, &param); // No need to check the return value

    switch (param) {
        case 0: // Count active processes
            result = getNumProc();
            break;
        case 1: // Return number of system calls made
            result = sys_call_count -1;
            break;
        case 2: // Return number of free memory pages
            result = count_free_pages();
            break;
        default: // Handle invalid parameter
            result = -1; // or some error code
    }

    return result;
}
