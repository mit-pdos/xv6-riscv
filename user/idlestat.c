//
// idlestat.c — Display per-CPU idle statistics (Feature 4: Halt-on-Idle)
//
// Shows how much time each CPU spent in WFI (Wait For Interrupt) idle state
// vs active scheduling, demonstrating energy-aware idle behavior.
//

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

// Per-CPU idle info layout matches what the kernel copies out:
//   [0] idle_ticks   — raw timer ticks spent in WFI
//   [1] total_ticks  — total scheduler loop iterations
//   [2] wfi_count    — number of times WFI was entered
struct idleinfo {
  uint64 idle_ticks;
  uint64 total_ticks;
  uint64 wfi_count;
};

int
main(int argc, char *argv[])
{
  struct idleinfo info[NCPU];
  int ncpus = NCPU;

  // Fetch idle stats from kernel
  if(idlestat(info, ncpus) < 0){
    printf("idlestat: syscall failed\n");
    exit(1);
  }

  printf("\n");
  printf("========================================\n");
  printf("  CPU Idle Statistics (Halt-on-Idle)\n");
  printf("========================================\n");
  printf("\n");

  uint64 total_idle = 0;
  uint64 total_all = 0;
  uint64 total_wfi = 0;
  int active_cpus = 0;

  for(int i = 0; i < ncpus; i++){
    uint64 it = info[i].idle_ticks;
    uint64 tt = info[i].total_ticks;
    uint64 wc = info[i].wfi_count;

    // Skip CPUs that have never run the scheduler
    if(tt == 0)
      continue;

    active_cpus++;

    // Compute idle percentage based on ratio of WFI entries
    // to total scheduler loop iterations
    uint64 idle_pct = (wc * 100) / tt;
    if(idle_pct > 100)
      idle_pct = 100;

    printf("  CPU %d:  wfi_entries=%ld  sched_loops=%ld  idle=%ld%%\n",
           i, wc, tt, idle_pct);

    total_idle += it;
    total_all += tt;
    total_wfi += wc;
  }

  printf("\n");
  printf("  ----------------------------------------\n");

  if(active_cpus > 0 && total_all > 0){
    uint64 avg_idle = (total_wfi * 100) / total_all;
    if(avg_idle > 100) avg_idle = 100;
    printf("  Active CPUs: %d\n", active_cpus);
    printf("  Total WFI entries: %ld\n", total_wfi);
    printf("  System-wide idle: ~%ld%%\n", avg_idle);
    printf("\n");
    printf("  Without WFI, idle CPUs would busy-wait\n");
    printf("  at 100%% power doing nothing useful.\n");
    printf("  WFI saves ~%ld%% of idle CPU energy.\n", avg_idle);
  } else {
    printf("  No active CPUs detected.\n");
  }

  printf("========================================\n");
  printf("\n");

  exit(0);
}
