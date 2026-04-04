// kernel/elog.c
#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "elog.h"

extern uint ticks;
extern struct spinlock tickslock;

struct {
  struct spinlock lock;
  struct elog_entry buf[ELOG_SIZE];
  int next_index;   // next position to write
  int count;        // number of valid entries
} elogsys;

static int
getticksafe(void)
{
  int t;
  acquire(&tickslock);
  t = ticks;
  release(&tickslock);
  return t;
}

void
eloginit(void)
{
  initlock(&elogsys.lock, "elog");
  elogsys.next_index = 0;
  elogsys.count = 0;
}

void
elogadd(int event_type, int sensor_id, int value)
{
  acquire(&elogsys.lock);

  struct elog_entry *e = &elogsys.buf[elogsys.next_index];
  e->timestamp = getticksafe();
  e->event_type = event_type;
  e->sensor_id = sensor_id;
  e->value = value;

  elogsys.next_index = (elogsys.next_index + 1) % ELOG_SIZE;
  if(elogsys.count < ELOG_SIZE)
    elogsys.count++;

  release(&elogsys.lock);
}

// Copies logs from oldest -> newest into dst.
// Returns number of entries copied.
int
elogread(struct elog_entry *dst, int max)
{
  int i, n, start;

  if(dst == 0 || max <= 0)
    return 0;

  acquire(&elogsys.lock);

  n = elogsys.count;
  if(max < n)
    n = max;

  start = (elogsys.next_index - elogsys.count + ELOG_SIZE) % ELOG_SIZE;

  for(i = 0; i < n; i++){
    dst[i] = elogsys.buf[(start + i) % ELOG_SIZE];
  }

  release(&elogsys.lock);
  return n;
}