#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

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
sys_getppid(void)
//New syscall to get the pid of the parent process
{
  struct proc *curr_proc = myproc();  //Pointer to the current process
  if(curr_proc->parent == (void*)0){  
    //If the current process has no parent, return -1
    return -1;
  }
  return curr_proc->parent->pid; //Return the pid of the parent process
}

uint64
sys_getancestror(void)
/*New syscall to get the pid of an ancestor at a given generation
* If the generation does not exist, return -1
* Generation 0 is the current process
* Generation 1 is the parent process
* Generation 2 is the grandparent process
* and so on...
*/
{
  int num_gen;                                                //Variable to get the number of generations via function argument
  argint(0,&num_gen);                                         //Get the number of generations from the function argument
  int cont_gen = 0;                                           
  struct proc *curr_proc = myproc();                          //Pointer to traverse the process tree
  while(curr_proc->parent != (void*)0 && cont_gen < num_gen){ //Traverse the process tree until we reach the desired generation or the root process
    cont_gen++; 
    curr_proc = curr_proc->parent;                            //Move to the parent process
  }
  if(cont_gen == num_gen){
    //If we have reached the desired generation, return the pid of that ancestor
    return curr_proc->pid; 
  }
  //If we have not reached the desired generation, return -1 (we have reached the root process)
  return -1;
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
