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

extern struct proc proc[NPROC];

uint64
sys_getprocsinfo(void)
{
    struct proc *p;

    printf("PID\tSTATE\tSIZE\n");

    for(p = proc; p < &proc[NPROC]; p++){
        if(p->state != UNUSED){
            printf("%d\t%d\t%ld\n", p->pid, p->state, p->sz);
        }
    }

    return 0;
}
uint64
sys_getppid(void)
{
    struct proc *p = myproc();
    if(p->parent)
        return p->parent->pid;
    return -1;
}
uint64
sys_sleep2(void)
{
    int n;
    argint(0, &n);

    struct proc *p = myproc();

    acquire(&tickslock);
    uint ticks0 = ticks;

    while(ticks - ticks0 < n){
        if(p->killed){
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    }

    release(&tickslock);
    return 0;
}
