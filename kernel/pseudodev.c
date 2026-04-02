#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"
#include "proc.h"
#include "defs.h"
#include "stat.h"
void
pseudodevregister(void)
{
  devsw[PSEUDODEV].read = pseudodevread;
  devsw[PSEUDODEV].write = pseudodevwrite;
}

enum {
  DEV_NULL = 0,
  DEV_ZERO = 1,
  DEV_URANDOM = 2,
  DEV_NULLSTAT = 3,
};

static struct spinlock pseudodev_lock;
static uint64 nullstat_count = 0;
static uint64 rand_seed = 1;

static uint64
lcg_next(void)
{
  rand_seed = rand_seed * 6364136223846793005ULL + 1;
  return rand_seed;
}

void
pseudodevinit(void)
{
  initlock(&pseudodev_lock, "pseudodev");
}

int
pseudodevread(short minor, int user_dst, uint64 dst, int n)
{
  int i;
  uchar ch;
  uint64 value;

  switch (minor) {
  case DEV_NULL:
    return 0;

  case DEV_ZERO:
    for (i = 0; i < n; i++) {
      ch = 0;
      if (either_copyout(user_dst, dst + i, &ch, 1) < 0)
        return -1;
    }
    return n;

  case DEV_URANDOM:
    for (i = 0; i < n; i++) {
      if ((i & 7) == 0)
        value = lcg_next();
      ch = (value >> ((i & 7) * 8)) & 0xFF;
      if (either_copyout(user_dst, dst + i, &ch, 1) < 0)
        return -1;
    }
    return n;

  case DEV_NULLSTAT:
    if (n != sizeof(uint64))
      return -1;
    acquire(&pseudodev_lock);
    value = nullstat_count;
    release(&pseudodev_lock);
    if (either_copyout(user_dst, dst, (char*)&value, sizeof(uint64)) < 0)
      return -1;
    return sizeof(uint64);

  default:
    return -1;
  }
}

int
pseudodevwrite(short minor, int user_src, uint64 src, int n)
{
  uint64 value;

  switch (minor) {
  case DEV_NULL:
    return n;

  case DEV_ZERO:
    return -1;

  case DEV_URANDOM:
    if (n != sizeof(uint64))
      return -1;
    if (either_copyin((char*)&value, user_src, src, sizeof(uint64)) < 0)
      return -1;
    rand_seed = value;
    return sizeof(uint64);

  case DEV_NULLSTAT:
    acquire(&pseudodev_lock);
    nullstat_count += n;
    release(&pseudodev_lock);
    return n;

  default:
    return -1;
  }
}