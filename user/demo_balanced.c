// user/demo_balanced.c
//
// Phase 1 demo — CPU Power State: LOW -> BALANCED
//
// Spawns 2 CPU-bound workers so the system has 3 runnable processes
// (parent + 2 children).  The kernel's power state should flip from
// LOW to BALANCED, which is visible in the energytop-style snapshot
// printed while the workers are still alive.
//
// Run:  $ demo_balanced

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define MAX_PROCS    64
#define SPIN_LONG   150000000   // keeps workers alive long enough to snapshot
#define SETTLE_TICKS 24         // kernel updates power state every 8 ticks

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

  // sort descending by energy_used
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
  printf("  DEMO: Power State LOW -> BALANCED\n");
  printf("  parent + 2 workers = 3 runnable processes\n");
  printf("==============================================\n\n");

  printf("  [before] tick %d\n", uptime());
  snapshot("baseline — LOW");

  printf("\n  Forking 2 workers...\n");
  int pids[2];
  for(int i=0;i<2;i++){
    pids[i] = fork();
    if(pids[i] == 0){ spin(SPIN_LONG); exit(0); }
  }

  snapshot("3 runnable — BALANCED");

  pause(2);
  snapshot("2 ticks later");

  for(int i=0;i<2;i++) wait(0);
  pause(8);

  printf("\n  Workers done.\n");
  snapshot("workers exited — LOW");

  printf("\n==============================================\n\n");
  exit(0);
}
