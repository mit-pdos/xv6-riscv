#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"

struct mlfq_queue {
  struct spinlock lock;
  struct proc *head;
  struct proc *tail;
  int size;
};

static struct mlfq_queue mlfq[MLFQ_LEVELS];

static int
mlfq_valid_priority(int priority)
{
  return priority >= 0 && priority < MLFQ_LEVELS;
}

static struct mlfq_queue *
mlfq_q(int priority)
{
  if(!mlfq_valid_priority(priority))
    panic("mlfq: bad priority");
  return &mlfq[priority];
}

void
mlfq_init(void)
{
  for(int i = 0; i < MLFQ_LEVELS; i++){
    initlock(&mlfq[i].lock, "mlfq");
    mlfq[i].head = 0;
    mlfq[i].tail = 0;
    mlfq[i].size = 0;
  }
}

void
mlfq_enqueue(struct proc *p, int priority)
{
  if(p == 0)
    panic("mlfq_enqueue: null proc");
  if(!mlfq_valid_priority(priority))
    panic("mlfq_enqueue: bad priority");

  struct mlfq_queue *q = mlfq_q(priority);

  acquire(&q->lock);

  // Enqueue is O(1). Caller is responsible for not enqueueing a proc twice.
  if(p->mlfq_level != -1)
    panic("mlfq_enqueue: proc already queued");

  p->mlfq_next = 0;
  p->mlfq_level = priority;

  if(q->tail){
    q->tail->mlfq_next = p;
    q->tail = p;
  } else {
    q->head = p;
    q->tail = p;
  }
  q->size++;

  release(&q->lock);
}

struct proc*
mlfq_dequeue(int priority)
{
  if(!mlfq_valid_priority(priority))
    panic("mlfq_dequeue: bad priority");

  struct mlfq_queue *q = mlfq_q(priority);

  acquire(&q->lock);

  struct proc *p = q->head;
  if(p == 0){
    release(&q->lock);
    return 0;
  }

  q->head = p->mlfq_next;
  if(q->head == 0)
    q->tail = 0;

  p->mlfq_next = 0;
  p->mlfq_level = -1;
  q->size--;

  release(&q->lock);
  return p;
}

int
mlfq_queue_empty(int priority)
{
  if(!mlfq_valid_priority(priority))
    panic("mlfq_queue_empty: bad priority");

  struct mlfq_queue *q = mlfq_q(priority);
  acquire(&q->lock);
  int empty = (q->size == 0);
  release(&q->lock);
  return empty;
}

int
mlfq_queue_size(int priority)
{
  if(!mlfq_valid_priority(priority))
    panic("mlfq_queue_size: bad priority");

  struct mlfq_queue *q = mlfq_q(priority);
  acquire(&q->lock);
  int n = q->size;
  release(&q->lock);
  return n;
}

static int
mlfq_remove_from_q(struct proc *p, int priority)
{
  struct mlfq_queue *q = mlfq_q(priority);

  acquire(&q->lock);

  struct proc *prev = 0;
  for(struct proc *cur = q->head; cur; cur = cur->mlfq_next){
    if(cur == p){
      if(prev)
        prev->mlfq_next = cur->mlfq_next;
      else
        q->head = cur->mlfq_next;

      if(q->tail == cur)
        q->tail = prev;

      cur->mlfq_next = 0;
      cur->mlfq_level = -1;
      q->size--;

      release(&q->lock);
      return 1;
    }
    prev = cur;
  }

  release(&q->lock);
  return 0;
}

void
mlfq_remove(struct proc *p)
{
  if(p == 0)
    return;

  int level = p->mlfq_level;
  if(mlfq_valid_priority(level)){
    if(mlfq_remove_from_q(p, level))
      return;
    // Fall through and scan if the hint was stale.
  }

  for(int i = 0; i < MLFQ_LEVELS; i++){
    if(mlfq_remove_from_q(p, i))
      return;
  }
}

