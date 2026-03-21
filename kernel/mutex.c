#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"

static int mutex_debug;
static int mutex_nlive;

int
mutex_debug_set(int cmd)
{
  if(cmd == -1)
    return mutex_nlive;

  int prev = mutex_debug;
  mutex_debug = (cmd != 0);

  return prev;
}

int
mutexalloc(struct file **f)
{
  struct file *file;
  struct sleeplock *lk;

  *f = 0;
  lk = 0;
  if ((file = filealloc()) == 0)
    return -1;
  
  if ((lk = (struct sleeplock*)kalloc()) == 0) {
    fileclose(file);
    return -1;
  }

  initsleeplock(lk, "mutex");

  mutex_nlive++;
  if(mutex_debug)
    printf("mutex: kalloc lk=%p pid=%d nlive=%d\n", lk, myproc()->pid, mutex_nlive);
  
  file->type = FD_MUTEX;
  file->readable = 0;
  file->writable = 0;
  file->mutex = lk;
  *f = file;

  return 0;
}

void
mutexclose(struct sleeplock *lk)
{
  mutex_nlive--;
  if(mutex_debug)
    printf("mutex: kfree lk=%p pid=%d nlive=%d\n", lk, myproc()->pid, mutex_nlive);

  kfree((char*)lk);
}
