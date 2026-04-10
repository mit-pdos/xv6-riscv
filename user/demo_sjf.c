// user/demo_sjf.c
//
// Phase 3 demo — SJF Scheduling in action
//
// Uses 7 competing processes on 3 CPUs (parent + 6 workers):
//   2 × SHORT  : spin(5M) + pause(2) × 10 rounds → EST_BST → 0
//   2 × MEDIUM : spin(200M) + pause(1) × 8 rounds → EST_BST → ~3-4
//   2 × LONG   : pure CPU spin(500M) × 4 rounds   → EST_BST → 5-10
//
// With 7 runnable and 3 CPUs, SJF always picks the lowest-EST_BST processes.
// SHORTs run most freely, MEDIUMs next, LONGs wait the longest — visible in
// their completion order and EST_BST spread.
//
// Run:  $ demo_sjf

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define MAX_PROCS      64

#define SPIN_SHORT     5000000    // ~0.1 ticks → EST_BST → 0
#define SPIN_MEDIUM  200000000    // ~4 ticks   → EST_BST → 3-4
#define SPIN_LONG    500000000    // ~10 ticks, fills timeslice → EST_BST → 5-10

#define SHORT_ROUNDS  10
#define MEDIUM_ROUNDS  8
#define LONG_ROUNDS    4

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
  printf("  | %-5s  %-12s  %6s  %6s  %7s |\n","PID","NAME","ENERGY","BUDGET","EST_BST");
  printf("  +------------------------------------------------+\n");
  int shown=0;
  for(int i=0;i<n;i++){
    if(rows[i].state==0) continue;
    printf("  | %-5d  %-12s  %6d  %6d  %7d |\n",
           rows[i].pid, rows[i].name,
           rows[i].energy_used, rows[i].energy_budget, rows[i].estimated_burst);
    shown++;
  }
  printf("  +------------------------------------------------+\n");
  printf("  | %d active process(es)                           |\n", shown);
  printf("  +------------------------------------------------+\n");
}

int
main(void)
{
  printf("\n");
  printf("==============================================\n");
  printf("  DEMO: SJF Scheduling\n");
  printf("  7 processes, 3 CPUs — scheduler must choose\n");
  printf("\n");
  printf("  SHORT  x2: spin(%d) + pause(2), %d rounds\n", SPIN_SHORT,  SHORT_ROUNDS);
  printf("  MEDIUM x2: spin(%d) + pause(1), %d rounds\n", SPIN_MEDIUM, MEDIUM_ROUNDS);
  printf("  LONG   x2: spin(%d), CPU-bound, %d rounds\n", SPIN_LONG,   LONG_ROUNDS);
  printf("\n");
  printf("==============================================\n\n");

  int start = uptime();
  printf("  Starting at tick %d\n\n", start);

  // Fork 2 SHORT workers
  int s1 = fork();
  if(s1 == 0){
    setprocname("SHORT-1");
    for(int i=0; i<SHORT_ROUNDS; i++){ spin(SPIN_SHORT); pause(2); }
    exit(0);
  }
  int s2 = fork();
  if(s2 == 0){
    setprocname("SHORT-2");
    for(int i=0; i<SHORT_ROUNDS; i++){ spin(SPIN_SHORT); pause(2); }
    exit(0);
  }

  // Fork 2 MEDIUM workers — partial burst then sleep → EST_BST ~3-4
  int m1 = fork();
  if(m1 == 0){
    setprocname("MEDIUM-1");
    for(int i=0; i<MEDIUM_ROUNDS; i++){ spin(SPIN_MEDIUM); pause(1); }
    exit(0);
  }
  int m2 = fork();
  if(m2 == 0){
    setprocname("MEDIUM-2");
    for(int i=0; i<MEDIUM_ROUNDS; i++){ spin(SPIN_MEDIUM); pause(1); }
    exit(0);
  }

  // Fork 2 LONG workers — purely CPU-bound, always preempted → EST_BST → timeslice
  int l1 = fork();
  if(l1 == 0){
    setprocname("LONG-1");
    for(int i=0; i<LONG_ROUNDS; i++){ spin(SPIN_LONG); }
    exit(0);
  }
  int l2 = fork();
  if(l2 == 0){
    setprocname("LONG-2");
    for(int i=0; i<LONG_ROUNDS; i++){ spin(SPIN_LONG); }
    exit(0);
  }

  printf("  Forked 6 workers.\n");
  pause(20);
  snapshot("tick +20");

  pause(15);
  snapshot("tick +35");

  printf("\n  Waiting for all workers to finish...\n");
  int finish_s1=0, finish_s2=0, finish_m1=0, finish_m2=0, finish_l1=0, finish_l2=0;
  for(int i=0; i<6; i++){
    int pid = wait(0);
    int t   = uptime();
    if(pid==s1){ finish_s1=t; printf("  SHORT-1  done at tick %d\n", t); }
    if(pid==s2){ finish_s2=t; printf("  SHORT-2  done at tick %d\n", t); }
    if(pid==m1){ finish_m1=t; printf("  MEDIUM-1 done at tick %d\n", t); }
    if(pid==m2){ finish_m2=t; printf("  MEDIUM-2 done at tick %d\n", t); }
    if(pid==l1){ finish_l1=t; printf("  LONG-1   done at tick %d\n", t); }
    if(pid==l2){ finish_l2=t; printf("  LONG-2   done at tick %d\n", t); }
  }

  snapshot("all workers done");

  printf("\n  --- Summary ---\n");
  printf("  SHORTs  finished: tick %d, tick %d\n", finish_s1, finish_s2);
  printf("  MEDIUMs finished: tick %d, tick %d\n", finish_m1, finish_m2);
  printf("  LONGs   finished: tick %d, tick %d\n", finish_l1, finish_l2);
  printf("  Total elapsed: %d ticks\n", uptime() - start);

  int short_avg  = (finish_s1 + finish_s2) / 2;
  int medium_avg = (finish_m1 + finish_m2) / 2;
  int long_avg   = (finish_l1 + finish_l2) / 2;

  if(short_avg < medium_avg && medium_avg < long_avg)
    printf("  SHORTs < MEDIUMs < LONGs — SJF working.\n");
  else if(short_avg < long_avg)
    printf("  SHORTs finished before LONGs — SJF working.\n");
  else
    printf("  WARNING: expected order not observed (see ticks above)\n");

  printf("\n==============================================\n\n");
  exit(0);
}
