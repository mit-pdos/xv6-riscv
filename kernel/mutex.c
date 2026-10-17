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
  struct proc *p = myproc();
  struct sleeplock *lock;
  lock = 0;

  if ((*f = filealloc()) == 0) {
    goto bad;
  }

  if ((lock = (struct sleeplock *)kalloc()) == 0) {
    goto bad;
  }

  initsleeplock(lock, "mutex");
  (*f)->type = FD_MUTEX;
  (*f)->readable = 1;
  (*f)->writable = 0;
  (*f)->lock = lock;

  printk("pid %d: mutexalloc & kalloc successful. lock_addr=%p\n", p->pid,
         lock);

  return 0;

bad:
  if (lock) {
    kfree(lock);
  }
  if (*f) {
    fileclose(*f);
  }
  printk("pid %d: mutexalloc failed\n", p->pid);
  return -1;
}

void
mutexclose(struct sleeplock *f)
{
  struct proc *p = myproc();
  printk("pid %d: mutexclose started for lock_addr=%p\n", p->pid, f);
  if (holdingsleep(f)) {
    printk("pid %d: mutexclose autofreeing lock lock_addr=%p\n", p->pid, f);
    releasesleep(f);
  }

  kfree(f);
  printk("pid %d: mutexclose kfree successful for lock_addr=%p\n", p->pid, f);
}

int
mutexlock(struct file *f)
{
  struct proc *p = myproc();

  if (f->type != FD_MUTEX || f->lock == 0) {
    return -1;
  }

  printk("pid %d: trying to lock_addr=%p\n", p->pid, f->lock);

  acquiresleep(f->lock);

  printk("pid %d: successfully acquired lock_addr=%p\n", p->pid, f->lock);
  return 0;
}

int
mutexunlock(struct file *f)
{
  struct proc *p = myproc();

  if (f->type != FD_MUTEX || f->lock == 0)
    return -1;

  if (!holdingsleep(f->lock)) {
    printk("pid %d: failed to unlock (not owner) lock_addr=%p\n", p->pid,
           f->lock);
    return -1;
  }

  printk("pid %d: releasing lock_addr=%p\n", p->pid, f->lock);

  releasesleep(f->lock);

  printk("pid %d: successfully released lock_addr=%p\n", p->pid, f->lock);
  return 0;
}
