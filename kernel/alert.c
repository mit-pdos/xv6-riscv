// kernel/alert.c
#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "alert.h"
#include "elog.h"

extern uint ticks;
extern struct spinlock tickslock;

struct {
  struct spinlock lock;
  struct alert_threshold thresholds[MAX_SENSORS];
  struct alert_entry buf[ALERT_BUF_SIZE];
  int next_index;
  int count;
} alertsys;

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
alertinit(void)
{
  initlock(&alertsys.lock, "alert");
  alertsys.next_index = 0;
  alertsys.count = 0;
  for(int i = 0; i < MAX_SENSORS; i++){
    alertsys.thresholds[i].active = 0;
  }
}

int
alertsetthreshold(int sensor_id, int min_val, int max_val)
{
  if(sensor_id < 1 || sensor_id > MAX_SENSORS)
    return -1;
  if(min_val > max_val)
    return -1;

  acquire(&alertsys.lock);

  struct alert_threshold *t = &alertsys.thresholds[sensor_id - 1];
  t->sensor_id = sensor_id;
  t->min_val = min_val;
  t->max_val = max_val;
  t->active = 1;

  release(&alertsys.lock);
  return 0;
}

void
alertcheck(int sensor_id, int value)
{
  int exceeded = 0;
  int thresh_val = 0;

  if(sensor_id < 1 || sensor_id > MAX_SENSORS)
    return;

  acquire(&alertsys.lock);

  struct alert_threshold *t = &alertsys.thresholds[sensor_id - 1];
  if(t->active){
    if(value > t->max_val){
      exceeded = 1;
      thresh_val = t->max_val;
    } else if(value < t->min_val){
      exceeded = 1;
      thresh_val = t->min_val;
    }

    if(exceeded){
      struct alert_entry *e = &alertsys.buf[alertsys.next_index];
      e->timestamp = getticksafe();
      e->sensor_id = sensor_id;
      e->value = value;
      e->threshold = thresh_val;
      e->alert_type = ALERT_WARNING;

      alertsys.next_index = (alertsys.next_index + 1) % ALERT_BUF_SIZE;
      if(alertsys.count < ALERT_BUF_SIZE)
        alertsys.count++;
    }
  }

  release(&alertsys.lock);

  // Log threshold breach into elog system (after releasing alert lock)
  if(exceeded)
    elogadd(EVENT_THRESHOLD_EXCEEDED, sensor_id, value);
}

int
alertgetpending(struct alert_entry *dst, int max)
{
  int i, n, start;

  if(dst == 0 || max <= 0)
    return 0;

  acquire(&alertsys.lock);

  n = alertsys.count;
  if(max < n)
    n = max;

  start = (alertsys.next_index - alertsys.count + ALERT_BUF_SIZE) % ALERT_BUF_SIZE;

  for(i = 0; i < n; i++){
    dst[i] = alertsys.buf[(start + i) % ALERT_BUF_SIZE];
  }

  release(&alertsys.lock);
  return n;
}
