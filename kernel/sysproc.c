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
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_getppid(void)
{
  return myproc()->parent->pid;
}
uint64 sys_square(void)
{
  int num;
  argint(0, &num);
  return  num *num;
}
uint64 sys_get_child_count(void)
{
  struct proc *p=myproc();
  int count;
  acquire(&p->lock);
  count=p->child_count;
  release(&p->lock);
  return count;
}

uint64 sys_get_process_child_count(void)
{
  int pid;
  argint(0, &pid);
  struct proc *p;
  for(int i=0;i<NPROC;i++)
  {
    p=&proc[i];
    acquire(&p->lock);
    if(p->state!=UNUSED && p->pid == pid)
    {
      int count=p->child_count;
      release(&p->lock);
      return count;
    }
    release(&p->lock);
  }
  return -1;
}
uint64
sys_nfork(void)
{
  int n;
  uint64 child_pids_addr;

  argint(0, &n);
  argaddr(1, &child_pids_addr);

  if (n <= 0 || child_pids_addr == 0)
    return -1;

  struct proc *p = myproc();

  for (int i = 0; i < n; i++) {
    int pid = kfork();
    if (pid < 0) {
      return i > 0 ? i : -1;
    }
    if (copyout(p->pagetable, p->sz, child_pids_addr + i * sizeof(int),
                (char *)&pid, sizeof(pid)) < 0) {
      return -1;
    }
  }
  return n;
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
sys_print_syscalls(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  for (int i = 0; i < MAX_SYSCALL; i++) {
    if (p->syscall_counts[i] > 0) {
      printk("syscall %d : %d\n", i, p->syscall_counts[i]);
    }
  }
  release(&p->lock);
  return 0;
}

uint64
sys_print_process_syscalls(void)
{
  int pid;
  argint(0, &pid);
  struct proc *p;
  for (int i = 0; i < NPROC; i++) {
    p = &proc[i];
    acquire(&p->lock);
    if (p->state != UNUSED && p->pid == pid) {
      for (int i = 0; i < MAX_SYSCALL; i++) {
        if (p->syscall_counts[i] > 0) {
          printk("syscall %d : %d\n", i, p->syscall_counts[i]);
        }
      }
      release(&p->lock);
    }
  }
  return 0;
  return -1;
}

uint64
sys_pte_valid(void)
{
  uint64 va;
  argaddr(0, &va);
  return ismapped(myproc()->pagetable, va);
}
uint64
sys_get_pteflags(void)
{
  uint64 va;
  argaddr(0,&va);
  get_pteflags(va);
  return 0;
}
uint64
sys_va2pa(void)
{
  uint64 va;
  argaddr(0,&va);

  uint64 pa=walkaddr(myproc()->pagetable,va);
  if(pa==0)
   return 0;

  return pa+(va&(PGSIZE-1));
}
uint64 sys_getvasize(void)
{
  int pid;
  argint(0, &pid);
  struct proc *p;
  for(int i=0;i<NPROC;i++)
  {
    p=&proc[i];
    acquire(&p->lock);
    if(p->state!=UNUSED && p->pid == pid)
    {
      uint64 size=p->sz;
      release(&p->lock);
      return size;
    }
    release(&p->lock);
  }
  return -1;
}