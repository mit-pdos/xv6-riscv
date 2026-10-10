#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "proc.h"

uint64
sys_mutex(void)
{
  struct file *f;
  int fd;

  if(mutexalloc(&f) < 0)
    return -1;

  if((fd = fdalloc(f)) < 0){
    fileclose(f);
    return -1;
  }

  return fd;
}

uint64
sys_mutex_lock(void)
{
  struct file *f;

  if(argfd(0, 0, &f) < 0)
    return -1;

  if(f->type != FD_MUTEX || f->mutex == 0)
    return -1;

  if(holdingsleep(f->mutex))
    return -1;

  printk("mutex %p: pid %d lock\n",
         f->mutex, myproc()->pid);

  acquiresleep(f->mutex);

  printk("mutex %p: pid %d acquired\n",
         f->mutex, myproc()->pid);

  return 0;
}

uint64
sys_mutex_unlock(void)
{
  struct file *f;

  if(argfd(0, 0, &f) < 0)
    return -1;

  if(f->type != FD_MUTEX || f->mutex == 0)
    return -1;

  if(!holdingsleep(f->mutex))
    return -1;

  printk("mutex %p: pid %d unlock\n",
         f->mutex, myproc()->pid);

  releasesleep(f->mutex);

  return 0;
}
