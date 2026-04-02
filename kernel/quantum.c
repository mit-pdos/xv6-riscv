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
  int quantum_factor_x1000;
  uint64 last_quantum_adjust_tick;
  uint64 total_context_switches;
  uint64 voluntary_context_switches;
  uint64 involuntary_context_switches;
  uint64 last_cs_count;
  uint64 last_cs_update_tick;
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
  qm.quantum_factor_x1000 = 1000;
  qm.last_quantum_adjust_tick = 0;
  qm.total_context_switches = 0;
  qm.voluntary_context_switches = 0;
  qm.involuntary_context_switches = 0;
  qm.last_cs_count = 0;
  qm.last_cs_update_tick = 0;
  qm.load_avg_x1000 = 0;
  qm.last_load_update_tick = 0;
}

void
qm_track_context_switch(int voluntary)
{
  acquire(&qm.lock);
  qm.total_context_switches++;
  if(voluntary)
    qm.voluntary_context_switches++;
  else
    qm.involuntary_context_switches++;
  release(&qm.lock);
}

static int
target_quantum_factor_x1000(int load)
{
  if(load < 5)
    return 1500;
  if(load < 20)
    return 1000;
  if(load < 50)
    return 700;
  return 500;
}

static void
adjust_quantum_by_load_locked(int load)
{
  int target = target_quantum_factor_x1000(load);
  const int alpha_num = 1;
  const int alpha_den = 5;
  qm.quantum_factor_x1000 = (qm.quantum_factor_x1000 * (alpha_den - alpha_num) + target * alpha_num) / alpha_den;

  for(int i = 0; i < MLFQ_LEVELS; i++){
    uint64 q = (qm.base_quantum[i] * (uint64)qm.quantum_factor_x1000) / 1000ULL;
    if(q < 2)
      q = 2;
    qm.current_quantum[i] = q;
  }
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

  const uint64 quantum_adjust_interval_ticks = 100;
  acquire(&qm.lock);
  if(qm.last_quantum_adjust_tick == 0 || now_tick - qm.last_quantum_adjust_tick >= quantum_adjust_interval_ticks){
    adjust_quantum_by_load_locked(qm.system_load);
    qm.last_quantum_adjust_tick = now_tick;
  }
  release(&qm.lock);

  const uint64 update_interval_ticks = 100;
  const int ticks_per_sec = 10;

  acquire(&qm.lock);
  if(qm.last_cs_update_tick == 0){
    qm.last_cs_update_tick = now_tick;
    qm.last_cs_count = qm.total_context_switches;
    release(&qm.lock);
    return;
  }

  uint64 elapsed = now_tick - qm.last_cs_update_tick;
  if(elapsed >= update_interval_ticks){
    uint64 cs_delta = qm.total_context_switches - qm.last_cs_count;
    int inst_rate_x1000 = 0;
    if(elapsed > 0){
      inst_rate_x1000 = (int)((cs_delta * 1000ULL * ticks_per_sec) / elapsed);
    }

    const int alpha_num = 3;
    const int alpha_den = 10;
    int old = qm.context_switch_rate_x1000;
    int neu = (old * (alpha_den - alpha_num) + inst_rate_x1000 * alpha_num) / alpha_den;
    qm.context_switch_rate_x1000 = neu;

    qm.last_cs_count = qm.total_context_switches;
    qm.last_cs_update_tick = now_tick;
  }
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

uint64
qm_get_time_quantum(int level)
{
  if(level < 0)
    level = 0;
  if(level >= MLFQ_LEVELS)
    level = MLFQ_LEVELS - 1;

  acquire(&qm.lock);
  uint64 q = qm.current_quantum[level];
  release(&qm.lock);
  return q;
}

int
qm_get_context_switch_rate_x1000(void)
{
  acquire(&qm.lock);
  int v = qm.context_switch_rate_x1000;
  release(&qm.lock);
  return v;
}

void
qm_get_context_switch_counts(uint64 *total, uint64 *voluntary, uint64 *involuntary)
{
  acquire(&qm.lock);
  if(total)
    *total = qm.total_context_switches;
  if(voluntary)
    *voluntary = qm.voluntary_context_switches;
  if(involuntary)
    *involuntary = qm.involuntary_context_switches;
  release(&qm.lock);
}
