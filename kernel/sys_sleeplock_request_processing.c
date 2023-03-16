#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "lockrequestprocessing.h"

#define SYS_GIVE_LOCK 0
#define SYS_FREE_LOCK 1
#define SYS_ACQUIRE_LOCK 2
#define SYS_RELEASE_LOCK 3

uint64 
sys_sleeplock_request_processing(void) 
{
  int type, lock_id;
  argint(0, &type);
  if (type == SYS_GIVE_LOCK)
    return give_lock();
  argint(1, &lock_id);
  if (type == SYS_FREE_LOCK)
    return free_lock(lock_id);
  else if (type == SYS_ACQUIRE_LOCK)
    return acquire_lock(lock_id);
  else if (type == SYS_RELEASE_LOCK)
    return release_lock(lock_id);
  return -1;
}