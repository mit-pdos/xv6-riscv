#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"

int
mutexalloc(struct file **f)
{
  struct sleeplock *lk = 0;

  *f = 0;

  if ((*f = filealloc()) == 0) // Если заняты все ячейки в файловой таблице
    goto bad;
  
  if (lk = (struct sleeplock*)kalloc() == 0)
    goto bad;

  printf("kalloc pid %d: sleeplock %p\n", myproc()->pid, lk);

  initsleeplock(lk, "mutex"); // Создается освобожденным

  (*f)->type = FD_MUTEX;
  (*f)->readable = 0;
  (*f)->writable = 0;
  (*f)->mutex = lk;

  printf("mutexalloc pid %d: mutex %p, file %p\n", myproc()->pid, lk, *f);
  return  0;

  bad:
    if(*f)
      fileclose(*f);
    return -1;
}

void
mutexclose(struct sleeplock *lk)
{
  printf("mutexclose pid %d: mutex %p\n", myproc()->pid, lk);
  printf("kfree pid %d: sleeplock %p\n", myproc()->pid, lk);
  kfree((void*)lk);
  
}