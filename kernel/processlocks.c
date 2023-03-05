#include "types.h"
#include "param.h"
#include "riscv.h"

#include "defs.h"

#include "spinlock.h"

#include "proc.h"

#include "sleeplock.h"

#define MAX_PROCESS_LOCKS 16

static struct sleeplock sleeplocks[MAX_PROCESS_LOCKS];
static unsigned char allocated[MAX_PROCESS_LOCKS];

void processlocks_init() {
  for (int id = 0; id < MAX_PROCESS_LOCKS; ++id) {
    initsleeplock(&sleeplocks[id], "processlock");
    allocated[id] = 0;
  }
}

int processlocks_allocate() {
  for (int id = 0; id < MAX_PROCESS_LOCKS; ++id) {
    struct sleeplock *sleeplk = &sleeplocks[id];
    acquire(&sleeplk->lk);
    if (!allocated[id]) {
      allocated[id] = 1;
      release(&sleeplk->lk);
      return id;
    }
    release(&sleeplk->lk);
  }
  return -1;
}

int processlocks_free(int processlock_id) {
  if (processlock_id < 0 || processlock_id >= MAX_PROCESS_LOCKS)
    return -1; // invalid process lock

  struct sleeplock *sleeplk = &sleeplocks[processlock_id];
  acquire(&sleeplk->lk);
  if (sleeplk->locked) {
    release(&sleeplk->lk);
    return -1; // cannot free a locked lock
  }
  allocated[processlock_id] = 0;
  release(&sleeplk->lk);
  return 0;
}

int processlocks_acquire(int processlock_id) {
  if (processlock_id < 0 || processlock_id >= MAX_PROCESS_LOCKS)
    return -1; // invalid process lock

  struct sleeplock *sleeplk = &sleeplocks[processlock_id];
  acquire(&sleeplk->lk);
  if (!allocated[processlock_id]) {
    release(&sleeplk->lk);
    return -1; // cannot acquire an unallocated process lock
  }
  while (sleeplk->locked)
    sleep(sleeplk, &sleeplk->lk);
  if (!allocated[processlock_id]) {
    release(&sleeplk->lk);
    return -1; // cannot acquire an unallocated process lock
  }
  sleeplk->locked = 1;
  sleeplk->pid = myproc()->pid;
  release(&sleeplk->lk);
  return 0;
}

int processlocks_release(int processlock_id) {
  if (processlock_id < 0 || processlock_id >= MAX_PROCESS_LOCKS)
    return -1;

  struct sleeplock *sleeplk = &sleeplocks[processlock_id];
  acquire(&sleeplk->lk);
  if (!allocated[processlock_id]) {
    release(&sleeplk->lk);
    return -1; // cannot release an unallocated process lock
  }
  sleeplk->locked = 0;
  sleeplk->pid = 0;
  wakeup(sleeplk);
  release(&sleeplk->lk);
  return 0;
}
