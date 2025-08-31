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

// Shared Memory System Calls
// Shared Memory System Calls
uint64
sys_shm_create(void)
{
    int key;
    argint(0, &key);
    return shm_create(key);
}

uint64
sys_shm_get(void)
{
    int key;
    argint(0, &key);
    return (uint64)shm_get(key);
}

uint64
sys_shm_close(void)
{
    int key;
    argint(0, &key);
    return shm_close(key);
}

// Mailbox System Calls
uint64
sys_mbox_create(void)
{
    int key;
    argint(0, &key);
    return mbox_create(key);
}

uint64
sys_mbox_send(void)
{
    int mbox_id, msg;
    argint(0, &mbox_id);
    argint(1, &msg);
    return mbox_send(mbox_id, msg);
}

uint64
sys_mbox_recv(void)
{
    int mbox_id;
    uint64 msg_user_addr; // Variable to hold the user-space address of msg

    argint(0, &mbox_id);
    argaddr(1, &msg_user_addr); // Fetch the user pointer address

    return mbox_recv(mbox_id, msg_user_addr); // Cast to int* pointer
}