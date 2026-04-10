// user/demo_budget.c
//
// Phase 4 demo — Per-Process Energy Budget (Feature 3)
//
// Each process starts with ENERGY_BUDGET_DEFAULT = 16 ticks per window.
// Every tick the process runs, the budget decrements by 1.  When it hits
// zero the scheduler applies a penalty (+4 to the SJF score), pushing
// the process behind others that still have budget remaining.
//
// After ENERGY_BUDGET_RESET_TICKS = 200 ticks the window rolls over and
// the budget resets to 16, preventing permanent starvation.
//
// What this demo shows:
//   Step 1 — snapshot before CPU burn  (budget near 16)
//   Step 2 — burn CPU hard for 4 long spins
//   Step 3 — snapshot after burn       (energy_used high, budget near 0)
//   Step 4 — wait 210 ticks for window reset
//   Step 5 — snapshot after reset      (budget back to 16)
//
// Run:  $ demo_budget

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define MAX_PROCS  64
#define SPIN_LONG  200000000  // ~4 ticks per spin; x4 = ~16 ticks — exhausts budget

struct energystat_row {
  int  pid;
  int  state;
  int  energy_used;
  int  energy_budget;
  int  estimated_burst;
  int  power_state;
  char name[16];
};

static void spin(int n) { volatile int x=0; for(int i=0;i<n;i++) x++; }

static const char *pname(int p){
  if(p==0) return "LOW";
  if(p==1) return "BALANCED";
  if(p==2) return "HIGH";
  return "?";
}

static void
snapshot(const char *label)
{
  struct energystat_row rows[MAX_PROCS];
  int n = energystat(rows, MAX_PROCS);
  if(n <= 0){ printf("  [snapshot failed]\n"); return; }

  for(int i=0;i<n-1;i++)
    for(int j=0;j<n-i-1;j++)
      if(rows[j].energy_used < rows[j+1].energy_used){
        struct energystat_row t=rows[j]; rows[j]=rows[j+1]; rows[j+1]=t;
      }

  int psys=0;
  for(int i=0;i<n;i++) if(rows[i].state!=0){ psys=rows[i].power_state; break; }

  printf("\n  +--[ %s | tick %-4d | Power: %-8s ]--+\n", label, uptime(), pname(psys));
  printf("  | %-5s  %-12s  %6s  %6s  %7s  %5s |\n","PID","NAME","ENERGY","BUDGET","EST_BST","SCORE");
  printf("  +----------------------------------------------------+\n");
  for(int i=0;i<n;i++){
    if(rows[i].state==0) continue;
    int score = rows[i].estimated_burst + (rows[i].energy_budget <= 0 ? 4 : 0);
    printf("  | %-5d  %-12s  %6d  %6d  %7d  %5d |\n",
           rows[i].pid, rows[i].name,
           rows[i].energy_used, rows[i].energy_budget,
           rows[i].estimated_burst, score);
  }
  printf("  +----------------------------------------------------+\n");
}

// Get this process's own row
static void
selfsnap(int mypid, int *used, int *budget)
{
  struct energystat_row rows[MAX_PROCS];
  int n = energystat(rows, MAX_PROCS);
  for(int i=0;i<n;i++){
    if(rows[i].pid == mypid){
      *used   = rows[i].energy_used;
      *budget = rows[i].energy_budget;
      return;
    }
  }
  *used = *budget = -1;
}

int
main(void)
{
  printf("\n");
  printf("==============================================\n");
  printf("  DEMO: Per-Process Energy Budget\n");
  printf("  Default budget  = 16 ticks per window\n");
  printf("  Reset interval  = 200 ticks\n");
  printf("  Penalty on zero = +4 to SJF score\n");
  printf("==============================================\n\n");

  int mypid = getpid();
  int used=0, budget=0;

  // Step 1: baseline
  selfsnap(mypid, &used, &budget);
  printf("  [step 1] Before burn — energy_used: %d  budget: %d\n", used, budget);
  snapshot("before burn");

  // Step 2: exhaust budget
  printf("\n  [step 2] Burning CPU (%d iters x 4)...\n", SPIN_LONG);
  for(int i=0;i<4;i++) spin(SPIN_LONG);

  // Step 3: after burn — budget=0, penalty active
  selfsnap(mypid, &used, &budget);
  printf("  [step 3] After burn  — energy_used: %d  budget: %d\n", used, budget);
  snapshot("after burn — budget=0, penalty +4 active");

  // Step 4: race against a fresh rival to show penalty
  printf("\n  [step 4] Forking RIVAL (fresh budget)...\n");

  int rival = fork();
  if(rival == 0){
    setprocname("RIVAL");
    // RIVAL stays light — tiny spins + long sleeps so it never exhausts
    // its budget. Score stays low (EST_BST~0, no penalty) the whole race.
    for(int i=0; i<40; i++){ spin(5000000); pause(2); }
    exit(0);
  }

  // Parent (budget=0, +4 penalty) does CPU-heavy work
  int t_start = uptime();
  for(int i=0; i<8; i++){ spin(SPIN_LONG); pause(1); }
  int t_self = uptime() - t_start;

  wait(0);

  selfsnap(mypid, &used, &budget);
  printf("  [step 5] Race done — demo_budget took %d ticks\n", t_self);
  snapshot("after race");

  // Step 6: wait for reset window
  printf("\n  [step 6] Waiting for budget window reset (200 ticks)...\n");
  pause(210);

  selfsnap(mypid, &used, &budget);
  printf("  [step 7] After reset — energy_used: %d  budget: %d\n", used, budget);
  snapshot("after reset — budget restored to 16");

  printf("\n==============================================\n\n");
  exit(0);
}
