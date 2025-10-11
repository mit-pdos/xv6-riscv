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

uint64
sys_hello(void) // hello syscall definition
{
  int n;
  argint(0, &n);
  print_hello(n);
  return 0;
}

uint64
sys_sysinfo(void)
{
  int param;
  
  // Get the parameter from the syscall argument
  argint(0, &param);
  
  if(param == 0) {
    // Return number of active processes
    return count_active_processes();
  }
  else if(param == 1) {
    // Return total syscalls (excluding current one)
    extern uint64 global_syscall_count;
    return global_syscall_count - 1;
  }
  else if(param == 2) {
    // Return number of free memory pages
    return count_free_pages();
  }
  else {
    return -1;
  }
}

uint64
sys_procinfo(void)
{
  uint64 addr;
  struct proc *p = myproc();
  
  // Get the user pointer argument
  argaddr(0, &addr);
  
  // Check for NULL pointer
  if(addr == 0)
    return -1;
  
  // Define the pinfo structure (must match user-space exactly)
  struct pinfo {
    int ppid;
    int syscall_count;
    int page_usage;
  } __attribute__((packed));
  
  struct pinfo info;
  
  // Fill in the parent PID
  if(p->parent)
    info.ppid = p->parent->pid;
  else
    info.ppid = 0;
  
  // Fill in syscall count (exclude current call)
  info.syscall_count = p->syscall_count - 1;
  
  // Calculate page usage (round up for partial pages)
  info.page_usage = p->sz / PGSIZE;
  if(p->sz % PGSIZE != 0)
    info.page_usage++;
  
  // Copy data to user space
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    return -1;
  
  return 0;
}