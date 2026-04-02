#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct quantum_manager {
  uint64 base_quantum[MLFQ_LEVELS];
  uint64 current_quantum[MLFQ_LEVELS];
  int system_load;
  uint64 last_adjustment;
  int context_switch_rate_x1000;
  struct spinlock lock;
  int load_avg_x1000;
  uint64 last_load_update_tick;
};

static struct quantum_manager qm;

void
qm_init(void)
{
  initlock(&qm.lock, "quantum_manager");
  for(int i = 0; i < MLFQ_LEVELS; i++){
    qm.base_quantum[i] = mlfq_base_quantum[i];
    qm.current_quantum[i] = mlfq_base_quantum[i];
  }
  qm.system_load = 0;
  qm.last_adjustment = 0;
  qm.context_switch_rate_x1000 = 0;
  qm.load_avg_x1000 = 0;
  qm.last_load_update_tick = 0;
}

static int
count_running_processes(void)
{
  int running = 0;
  for(int i = 0; i < NCPU; i++){
    if(cpus[i].proc != 0)
      running++;
  }
  return running;
}

int
count_runnable_processes(void)
{
  int count = 0;
  for(int i = 0; i < MLFQ_LEVELS; i++){
    count += mlfq_queue_size(i);
  }
  count += count_running_processes();
  return count;
}

static void
commit_system_load_locked(uint64 now_tick, int load)
{
  qm.system_load = load;
  if(qm.last_load_update_tick == 0){
    qm.load_avg_x1000 = load * 1000;
  } else {
    const int alpha_num = 1;
    const int alpha_den = 5;
    int old = qm.load_avg_x1000;
    int neu = (old * (alpha_den - alpha_num) + (load * 1000) * alpha_num) / alpha_den;
    qm.load_avg_x1000 = neu;
  }
  qm.last_load_update_tick = now_tick;
}

void
qm_tick(uint64 now_tick)
{
  if(now_tick == 0)
    return;

  int do_update = 0;
  acquire(&qm.lock);
  if(qm.last_adjustment == 0 || now_tick - qm.last_adjustment >= 10){
    qm.last_adjustment = now_tick;
    do_update = 1;
  }
  release(&qm.lock);

  if(!do_update)
    return;

  int load = count_runnable_processes();

  acquire(&qm.lock);
  commit_system_load_locked(now_tick, load);
  release(&qm.lock);
}

int
qm_get_system_load(void)
{
  acquire(&qm.lock);
  int load = qm.system_load;
  release(&qm.lock);
  return load;
}

int
qm_get_loadavg_x1000(void)
{
  acquire(&qm.lock);
  int v = qm.load_avg_x1000;
  release(&qm.lock);
  return v;
}
