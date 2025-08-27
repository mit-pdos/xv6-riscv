// kernel/sem.c

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

struct semaphore sems[NSEM];
struct spinlock sems_lock; // protects the sems array

void
seminit(void)
{
  initlock(&sems_lock, "sems");
  for(int i = 0; i < NSEM; i++) {
    initlock(&sems[i].lock, "semaphore");
    sems[i].valid = 0;
  }
}

int
sem_init(int sem_id, int value)
{
  if(sem_id < 0 || sem_id >= NSEM) {
    return -1; // Invalid ID
  }

  // This function now acts as a reset if the semaphore is already valid.
  acquire(&sems_lock);
  sems[sem_id].count = value;
  sems[sem_id].valid = 1;
  release(&sems_lock);

  return 0;
}
// sem_down(int sem_id) -> P operation
// sem_down(int sem_id) -> P operation
int
sem_down(int sem_id)
{
  if(sem_id < 0 || sem_id >= NSEM) {
    return -1;
  }
  
  // Acquire the global lock to safely check the valid flag.
  acquire(&sems_lock);
  if(!sems[sem_id].valid) {
    release(&sems_lock);
    return -1; // Not initialized
  }
  release(&sems_lock);

  struct semaphore *s = &sems[sem_id];

  acquire(&s->lock);
  while(s->count == 0) {
    sleep(s, &s->lock);
  }
  s->count--;
  release(&s->lock);
  
  return 0;
}

// sem_up(int sem_id) -> V operation
int
sem_up(int sem_id)
{
  if(sem_id < 0 || sem_id >= NSEM) {
    return -1;
  }

  // Acquire the global lock to safely check the valid flag.
  acquire(&sems_lock);
  if(!sems[sem_id].valid) {
    release(&sems_lock);
    return -1; // Not initialized
  }
  release(&sems_lock);

  struct semaphore *s = &sems[sem_id];
  
  acquire(&s->lock);
  s->count++;
  wakeup(s);
  release(&s->lock);

  return 0;
}