// user/demo_idle.c
//
// Feature 4 demo — Halt-on-Idle (WFI)
//
// When no processes are RUNNABLE, each CPU executes the RISC-V WFI
// (Wait For Interrupt) instruction, halting until the next timer tick.
// This demo measures WFI entries during an idle window vs a busy window
// to show the contrast.
//


#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

struct idleinfo {
  uint64 idle_ticks;
  uint64 total_ticks;
  uint64 wfi_count;
};

static void
get_stats(struct idleinfo *out)
{
  idlestat(out, NCPU);
}

static void
print_delta(const char *label,
            struct idleinfo *before, struct idleinfo *after)
{
  printf("  %s\n", label);
  printf("  %-6s  %10s  %10s  %6s\n", "CPU", "sched_loops", "wfi_entries", "idle%");
  printf("  -----------------------------------------------\n");

  uint64 total_loops = 0, total_wfi = 0;
  for(int i = 0; i < NCPU; i++){
    uint64 loops = after[i].total_ticks - before[i].total_ticks;
    uint64 wfi   = after[i].wfi_count   - before[i].wfi_count;
    if(loops == 0) continue;
    uint64 pct = (wfi * 100) / loops;
    if(pct > 100) pct = 100;
    printf("  CPU %d   %10ld  %10ld  %5ld%%\n", i, loops, wfi, pct);
    total_loops += loops;
    total_wfi   += wfi;
  }
  if(total_loops > 0){
    uint64 avg = (total_wfi * 100) / total_loops;
    if(avg > 100) avg = 100;
    printf("  -----------------------------------------------\n");
    printf("  Total   %10ld  %10ld  %5ld%%\n\n", total_loops, total_wfi, avg);
  }
}

int
main(void)
{
  struct idleinfo before[NCPU], mid[NCPU], after[NCPU];

  printf("\n");
  printf("==============================================\n");
  printf("  DEMO: Halt-on-Idle (WFI)\n");
  printf("==============================================\n\n");

  printf("  [phase 1] Idle — 10 ticks, nothing running\n");
  get_stats(before);
  pause(10);
  get_stats(mid);

  print_delta("IDLE:", before, mid);

  printf("  [phase 2] Forking %d CPU-bound workers...\n", NCPU);
  int pids[NCPU];
  for(int i = 0; i < NCPU; i++){
    pids[i] = fork();
    if(pids[i] == 0){
      // spin for 15 ticks worth of work
      volatile int x = 0;
      for(int j = 0; j < 750000000; j++) x++;
      exit(0);
    }
  }

  // Let workers get scheduled and fill CPUs
  pause(1);
  get_stats(mid);
  pause(10);
  get_stats(after);

  for(int i = 0; i < NCPU; i++) wait(0);

  print_delta("BUSY:", mid, after);

  printf("==============================================\n\n");
  exit(0);
}
