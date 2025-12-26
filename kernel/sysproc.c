#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
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


#ifdef LAB_PGTBL
int
sys_pgaccess(void)
{
  //Lấy tham số thứ nhất lưu ở thanh ghi a_0 là địa chỉ ảo bắt đầu trang người dùng
  uint64 base;
  argaddr(0,&base);
  //Lấy tham số thứ hai là số trâng ở thanh ghi a_1
  int numOfPage;
  argint(1, &numOfPage);
  //Lấy tham số thứ ba là địa chỉ con trỏ buffer (64-bit) ở thanh ghi a2
  uint64 userMask;
  argaddr(2, &userMask);

  uint64 result = 0;
  struct proc *p = myproc();

  for(int i = 0; i < numOfPage; i++)
  {
    uint64 virtualAddr = base + 4096*i;

    pte_t *pte = walk(p->pagetable, virtualAddr, 0);

    if(pte != 0 && (*pte & PTE_A))
    {
      result |= (1L << i);
      *pte = *pte & ~PTE_A;
    }
  }
  if(copyout(p->pagetable, userMask, (char *)&result, sizeof(result)) < 0)
    return -1;
  return 0;
}
#endif

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

uint64
sys_setvmprintflag(void)
{
  int flag;
  // Lấy đối số thứ nhất (flag) từ userspace
  argint(0, &flag);

  struct proc *p = myproc();
  
  // Thiết lập cờ in bảng trang trong struct proc
  p->print_pagetable = (flag != 0); 
  
  return 0; // Thành công
}