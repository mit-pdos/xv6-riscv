#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "file.h"
#include "proc.h"

uint64
sys_mutex(void)
{
  struct file *f;

  if(mutexalloc(&f) < 0)
    return -1;
  int fd = fdalloc(f);
  if(fd < 0) {
    fileclose(f); 
    return -1;
  }
  return fd;
}


uint64
sys_mutex_lock(void)
{
  struct file *f;

  if(argfd(0, 0, &f) < 0) {
    return -1; 
  }
  if(f->type != FD_MUTEX)
    return -1;
  
  printf("mutex_lock: pid %d, mutex %p\n", myproc()->pid, f->mutex);
  
  acquiresleep(f->mutex); 
  
  return 0;
}

uint64
sys_mutex_unlock(void)
{
  struct file *f;
  if(argfd(0, 0, &f) < 0) {
    return -1; 
  }
  if(f->type != FD_MUTEX)
    return -1;

  printf("mutex_unlock: pid %d, mutex %p\n", myproc()->pid, f->mutex);
  
  releasesleep(f->mutex);
  
  return 0;
}