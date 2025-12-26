#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "../uproc.h"
#include "vm.h"


extern struct proc proc[NPROC];

extern int getprocs(struct uproc *up, int max);

uint64
sys_getprocs(void)
{
    uint64 uaddr;
    int max;

    argaddr(0, &uaddr);
    argint(1, &max);

    struct proc *p;
    struct uproc up;
    int count = 0;

    for(p = proc; p < &proc[NPROC] && count < max; p++){
        acquire(&p->lock);
        if(p->state != UNUSED){
            up.pid   = p->pid;
            up.nice  = p->nice;
            up.state = p->state;
            up.vruntime = p->vruntime;
            safestrcpy(up.name, p->name, sizeof(up.name));

            if(copyout(myproc()->pagetable,
                       uaddr + count * sizeof(struct uproc),
                       (char *)&up,
                       sizeof(up)) < 0){
                release(&p->lock);
                return -1;
            }
            count++;
        }
        release(&p->lock);
    }

    return count;
}



uint64
sys_setnice(void)
{
    int pid, nice;

    argint(0, &pid);
    argint(1, &nice);

    return setnice(pid, nice);
}
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

uint64
sys_physaddr(void)
{
    int va_int;
    struct proc *p = myproc();

    argint(0, &va_int);
    uint64 va = (uint64)va_int;

    pte_t *pte = walk(p->pagetable, va, 0);
    if (pte == 0 || (*pte & PTE_V) == 0)
        return -1;

    return PTE2PA(*pte) >> PGSHIFT;
}


