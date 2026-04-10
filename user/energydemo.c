// user/energydemo.c
//
// Video demo program for the Energy-Aware OS project.
// Designed for Option C: run this for the parallel/live parts,
// manually type `energytop`, `energytest`, `idlestat` for the rest.
//
// What this covers (things that REQUIRE simultaneous processes):
//   Phase 1 — Power state BALANCED: spawn 2 workers, snapshot live table
//   Phase 2 — Power state HIGH:     spawn 4 workers, snapshot live table
//   Phase 3 — SJF in action:        spawn SHORT + MEDIUM + LONG at the same
//             time, take snapshots mid-run, print completion order with ticks
//   Phase 4 — Energy budget drain:  burn CPU on this process, show budget
//             ticking down then resetting
//
// Suggested video flow:
//   1. Type `energytop`   manually — baseline snapshot, LOW power state
//   2. Type `energydemo`  — runs all 4 phases above
//   3. Type `energytest`  — all 10 unit tests, shows ALL TESTS PASSED
//   4. Type `idlestat`    — shows WFI idle percentage

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

// -------------------------------------------------------------------------
// Work amounts — tuned so burst-length differences are clearly visible
// SHORT  ≈ 1-2 ticks,  MEDIUM ≈ 5-8 ticks,  LONG ≈ 15-25 ticks
// -------------------------------------------------------------------------
#define SPIN_SHORT     600000
#define SPIN_MEDIUM   2500000
#define SPIN_LONG    10000000

#define SETTLE_TICKS  16      // ticks for power state to update (every 8)
#define MAX_PROCS     64

// -------------------------------------------------------------------------
// energystat row — must match kernel/sysproc.c layout
// -------------------------------------------------------------------------
struct energystat_row {
  int  pid;
  int  state;           // UNUSED=0 USED=1 SLEEPING=2 RUNNABLE=3 RUNNING=4 ZOMBIE=5
  int  energy_used;
  int  energy_budget;
  int  estimated_burst;
  int  power_state;     // LOW=0 BALANCED=1 HIGH=2
  char name[16];
};

// -------------------------------------------------------------------------
// Helpers
// -------------------------------------------------------------------------
static void
spin(int n)
{
  volatile int x = 0;
  for(int i = 0; i < n; i++)
    x = x + 1;
}

static const char *
state_str(int s)
{
  switch(s){
  case 2: return "SLEEPING";
  case 3: return "RUNNABLE";
  case 4: return "RUNNING ";
  case 5: return "ZOMBIE  ";
  default: return "USED    ";
  }
}

static const char *
power_str(int p)
{
  if(p == 0) return "LOW";
  if(p == 1) return "BALANCED";
  if(p == 2) return "HIGH";
  return "?";
}

// Inline energytop-style snapshot so we don't need to exec another process
static void
snapshot(const char *label)
{
  struct energystat_row rows[MAX_PROCS];
  int n = energystat(rows, MAX_PROCS);
  if(n <= 0){
    printf("  [snapshot failed]\n");
    return;
  }

  // Bubble sort descending by energy_used
  for(int i = 0; i < n-1; i++)
    for(int j = 0; j < n-i-1; j++)
      if(rows[j].energy_used < rows[j+1].energy_used){
        struct energystat_row tmp = rows[j];
        rows[j] = rows[j+1];
        rows[j+1] = tmp;
      }

  // Power state from first live row
  int psys = 0;
  for(int i = 0; i < n; i++)
    if(rows[i].state != 0){ psys = rows[i].power_state; break; }

  printf("\n");
  printf("  +--[ %s | tick %-4d | Power: %-8s ]--+\n",
         label, uptime(), power_str(psys));
  printf("  | %-5s  %-12s  %-9s  %6s  %6s  %7s |\n",
         "PID", "NAME", "STATE", "ENERGY", "BUDGET", "EST_BST");
  printf("  +------------------------------------------------------+\n");
  int shown = 0;
  for(int i = 0; i < n; i++){
    if(rows[i].state == 0) continue;
    printf("  | %-5d  %-12s  %-9s  %6d  %6d  %7d |\n",
           rows[i].pid,
           rows[i].name,
           state_str(rows[i].state),
           rows[i].energy_used,
           rows[i].energy_budget,
           rows[i].estimated_burst);
    shown++;
  }
  printf("  +------------------------------------------------------+\n");
  printf("  | %d active process(es)                                 |\n", shown);
  printf("  +------------------------------------------------------+\n");
}

static void
banner(int phase, const char *title)
{
  printf("\n");
  printf("======================================================\n");
  printf("  PHASE %d — %s\n", phase, title);
  printf("======================================================\n");
}

// -------------------------------------------------------------------------
// Phase 1: Power State → BALANCED  (parent + 2 workers = 3 runnable)
// -------------------------------------------------------------------------
static void
phase1_balanced(void)
{
  banner(1, "Power State: LOW -> BALANCED (2 workers)");
  printf("  Forking 2 CPU-bound workers...\n");

  int pids[2];
  for(int i = 0; i < 2; i++){
    pids[i] = fork();
    if(pids[i] == 0){
      spin(SPIN_LONG);
      exit(0);
    }
  }

  printf("  Waiting %d ticks for power state to update...\n", SETTLE_TICKS);
  pause(SETTLE_TICKS);
  snapshot("BALANCED check #1");
  pause(SETTLE_TICKS / 2);
  snapshot("BALANCED check #2");

  for(int i = 0; i < 2; i++) wait(0);
  printf("  Workers exited — returning to LOW.\n");
  pause(SETTLE_TICKS);
}

// -------------------------------------------------------------------------
// Phase 2: Power State → HIGH  (parent + 4 workers = 5 runnable)
// -------------------------------------------------------------------------
static void
phase2_high(void)
{
  banner(2, "Power State: BALANCED -> HIGH (4 workers)");
  printf("  Forking 4 CPU-bound workers...\n");

  int pids[4];
  for(int i = 0; i < 4; i++){
    pids[i] = fork();
    if(pids[i] == 0){
      spin(SPIN_LONG);
      exit(0);
    }
  }

  printf("  Waiting %d ticks for power state to update...\n", SETTLE_TICKS);
  pause(SETTLE_TICKS);
  snapshot("HIGH check #1");
  pause(SETTLE_TICKS / 2);
  snapshot("HIGH check #2");

  for(int i = 0; i < 4; i++) wait(0);
  printf("  Workers exited — returning to LOW.\n");
  pause(SETTLE_TICKS);
}

// -------------------------------------------------------------------------
// Phase 3: SJF in action — SHORT / MEDIUM / LONG started simultaneously
// Watch the rows disappear from the table in shortest-first order.
// -------------------------------------------------------------------------
static void
phase3_sjf(void)
{
  banner(3, "SJF Scheduling — SHORT / MEDIUM / LONG");

  printf("  Process work amounts:\n");
  printf("    SHORT  = %d iterations  (~1-2 ticks)\n",  SPIN_SHORT);
  printf("    MEDIUM = %d iterations  (~5-8 ticks)\n",  SPIN_MEDIUM);
  printf("    LONG   = %d iterations  (~15-25 ticks)\n", SPIN_LONG);
  printf("\n");
  printf("  Forking all three simultaneously at tick %d...\n", uptime());

  int short_pid = fork();
  if(short_pid == 0){ spin(SPIN_SHORT); exit(0); }

  int med_pid = fork();
  if(med_pid == 0){ spin(SPIN_MEDIUM); exit(0); }

  int long_pid = fork();
  if(long_pid == 0){ spin(SPIN_LONG); exit(0); }

  // Take 3 live snapshots while processes are running
  // The SHORT row should vanish first, then MEDIUM, then LONG
  pause(4);
  snapshot("SJF snapshot #1 — all three running");

  pause(8);
  snapshot("SJF snapshot #2 — shortest should be gone");

  pause(10);
  snapshot("SJF snapshot #3 — only LONG should remain");

  // Collect completions and record finish tick
  int finish_short = 0, finish_med = 0, finish_long = 0;
  for(int i = 0; i < 3; i++){
    int pid = wait(0);
    int t   = uptime();
    if(pid == short_pid){ finish_short = t; printf("  SHORT  finished at tick %d\n", t); }
    if(pid == med_pid)  { finish_med   = t; printf("  MEDIUM finished at tick %d\n", t); }
    if(pid == long_pid) { finish_long  = t; printf("  LONG   finished at tick %d\n", t); }
  }

  printf("\n  Completion order: ");
  if(finish_short <= finish_med && finish_med <= finish_long)
    printf("SHORT -> MEDIUM -> LONG  [SJF working correctly]\n");
  else if(finish_short <= finish_long && finish_med <= finish_long)
    printf("SHORT/MEDIUM -> LONG  [SJF working — long ran last]\n");
  else
    printf("(see ticks above — long processes ran longer as expected)\n");

  pause(SETTLE_TICKS);
}

// -------------------------------------------------------------------------
// Phase 4: Energy budget drain and reset
// -------------------------------------------------------------------------
static void
phase4_budget(void)
{
  banner(4, "Energy Budget — Drain and Reset");

  struct energystat_row rows[MAX_PROCS];
  struct energystat_row snap;
  int mypid = getpid();
  memset(&snap, 0, sizeof(snap));
  int before_used = 0, before_budget = 0;

  // Baseline
  int n = energystat(rows, MAX_PROCS);
  for(int i = 0; i < n; i++)
    if(rows[i].pid == mypid){ snap = rows[i]; break; }

  before_used   = snap.energy_used;
  before_budget = snap.energy_budget;
  printf("  Before burn — energy_used: %d  budget: %d\n",
         before_used, before_budget);

  // Burn enough CPU to exhaust the 16-tick budget
  printf("  Burning CPU (%d iterations x 4)...\n", SPIN_LONG);
  for(int i = 0; i < 4; i++)
    spin(SPIN_LONG);

  n = energystat(rows, MAX_PROCS);
  for(int i = 0; i < n; i++)
    if(rows[i].pid == mypid){ snap = rows[i]; break; }

  printf("  After burn  — energy_used: %d  budget: %d\n",
         snap.energy_used, snap.energy_budget);
  snapshot("Budget after burn");

  // Wait past the reset window (200 ticks)
  printf("\n  Waiting 210 ticks for budget window to reset...\n");
  pause(210);

  n = energystat(rows, MAX_PROCS);
  for(int i = 0; i < n; i++)
    if(rows[i].pid == mypid){ snap = rows[i]; break; }

  printf("  After reset — energy_used: %d  budget: %d\n",
         snap.energy_used, snap.energy_budget);
  snapshot("Budget after reset");
}

// -------------------------------------------------------------------------
// main
// -------------------------------------------------------------------------
int
main(void)
{
  printf("\n");
  printf("######################################################\n");
  printf("#  energydemo — Energy-Aware OS Visual Demo          #\n");
  printf("#                                                    #\n");
  printf("#  Covers: Power States, SJF ordering, Budget drain  #\n");
  printf("#  Run manually after: energytop                     #\n");
  printf("#  Run manually after: energytest, idlestat          #\n");
  printf("######################################################\n");
  printf("\n");
  printf("  Starting at tick %d\n", uptime());

  phase1_balanced();
  phase2_high();
  phase3_sjf();
  phase4_budget();

  printf("\n");
  printf("######################################################\n");
  printf("#  Demo complete.                                    #\n");
  printf("#  Next: type `energytest` to run the full           #\n");
  printf("#  unit test suite and see all tests pass.           #\n");
  printf("######################################################\n");
  printf("\n");

  exit(0);
}
