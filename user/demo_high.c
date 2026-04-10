// user/demo_high.c
//
// Phase 2 demo — CPU Power State: LOW -> HIGH
//
// Spawns 4 CPU-bound workers so the system has 5 runnable processes
// (parent + 4 children).  The kernel's power state should flip to HIGH,
// giving each process a longer timeslice (10 ticks) to reduce context-
// switch overhead under heavy load.
//
// Run:  $ demo_high

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define MAX_PROCS    64
#define SPIN_LONG   150000000
#define SETTLE_TICKS 24

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
  for(int i=0;i<n;i++){
    if(rows[i].state==0) continue;
    printf("  | %-5d  %-12s  %6d  %6d  %7d |\n",
           rows[i].pid, rows[i].name,
           rows[i].energy_used, rows[i].energy_budget, rows[i].estimated_burst);
  }
  printf("  +------------------------------------------------+\n");
}

int
main(void)
{
  printf("\n");
  printf("==============================================\n");
  printf("  DEMO: Power State LOW -> HIGH\n");
  printf("  parent + 4 workers = 5 runnable processes\n");
  printf("==============================================\n\n");

  printf("  [before] tick %d\n", uptime());
  snapshot("baseline — LOW");

  printf("\n  Forking 4 workers...\n");
  int pids[4];
  for(int i=0;i<4;i++){
    pids[i] = fork();
    if(pids[i] == 0){ spin(SPIN_LONG); exit(0); }
  }

  snapshot("5 runnable — HIGH");

  pause(2);
  snapshot("2 ticks later");

  for(int i=0;i<4;i++) wait(0);
  pause(8);

  printf("\n  Workers done.\n");
  snapshot("workers exited — LOW");

  printf("\n==============================================\n\n");
  exit(0);
}
