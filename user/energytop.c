// user/energytop.c
//
// Feature 5: energystat Syscall + energytop Userspace Tool
//
// Displays a live ranked table of all processes sorted by energy consumed.
// Mirrors the design of Unix `top` — each refresh clears and reprints the table.
//
// Usage:
//   energytop           — single snapshot
//   energytop N         — refresh N times, pausing 5 ticks between each
//
// Columns:
//   PID       process ID
//   NAME      process name
//   STATE     scheduler state
//   ENERGY    total CPU ticks consumed this window
//   BUDGET    remaining energy budget this window
//   EST_BURST predicted next burst length (from SJF exponential averaging)
//   POWER     system-wide power state (LOW / BALANCED / HIGH)
//
// How to read it:
//   Processes are sorted descending by ENERGY — the hungriest process is
//   always at the top.  BUDGET counts down from ENERGY_BUDGET_DEFAULT (16)
//   as the process burns CPU; when it hits 0 the scheduler applies a penalty.
//   EST_BURST converges toward the process's true burst length over time.

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define MAX_PROCS  64   // matches NPROC in param.h

// Must match the layout of struct energystat_row in kernel/sysproc.c
struct energystat_row {
  int  pid;
  int  state;           // enum procstate value
  int  energy_used;
  int  energy_budget;
  int  estimated_burst;
  int  power_state;     // 0=LOW 1=BALANCED 2=HIGH
  char name[16];
};

static const char *
state_str(int s)
{
  switch(s) {
  case 0: return "UNUSED  ";
  case 1: return "USED    ";
  case 2: return "SLEEPING";
  case 3: return "RUNNABLE";
  case 4: return "RUNNING ";
  case 5: return "ZOMBIE  ";
  default: return "?       ";
  }
}

static const char *
power_str(int p)
{
  switch(p) {
  case 0: return "LOW     ";
  case 1: return "BALANCED";
  case 2: return "HIGH    ";
  default: return "?       ";
  }
}

// Bubble sort descending by energy_used
static void
sort_by_energy(struct energystat_row *rows, int n)
{
  for(int i = 0; i < n - 1; i++) {
    for(int j = 0; j < n - i - 1; j++) {
      if(rows[j].energy_used < rows[j+1].energy_used) {
        struct energystat_row tmp = rows[j];
        rows[j] = rows[j+1];
        rows[j+1] = tmp;
      }
    }
  }
}

static void
print_table(struct energystat_row *rows, int n, int iter, int total)
{
  // Determine system power state from any live row
  int psys = 0;
  for(int i = 0; i < n; i++) {
    if(rows[i].state != 0) {
      psys = rows[i].power_state;
      break;
    }
  }

  printf("\n");
  printf("========================================================\n");
  printf("  energytop  [%d/%d]  uptime: %d ticks\n", iter, total, uptime());
  printf("  System Power State: %s\n", power_str(psys));
  printf("========================================================\n");
  printf("%-6s  %-14s  %-9s  %7s  %7s  %8s\n",
         "PID", "NAME", "STATE", "ENERGY", "BUDGET", "EST_BST");
  printf("--------------------------------------------------------\n");

  int shown = 0;
  for(int i = 0; i < n; i++) {
    if(rows[i].state == 0) continue;  // skip UNUSED slots
    printf("%-6d  %-14s  %-9s  %7d  %7d  %8d\n",
           rows[i].pid,
           rows[i].name,
           state_str(rows[i].state),
           rows[i].energy_used,
           rows[i].energy_budget,
           rows[i].estimated_burst);
    shown++;
  }

  printf("--------------------------------------------------------\n");
  printf("  %d active process(es)\n", shown);
  printf("========================================================\n");
}

int
main(int argc, char *argv[])
{
  struct energystat_row rows[MAX_PROCS];
  int iters = 1;

  if(argc >= 2) {
    iters = atoi(argv[1]);
    if(iters <= 0) iters = 1;
  }

  for(int i = 1; i <= iters; i++) {
    int n = energystat(rows, MAX_PROCS);
    if(n < 0) {
      printf("energytop: energystat syscall failed\n");
      exit(1);
    }

    sort_by_energy(rows, n);
    print_table(rows, n, i, iters);

    if(i < iters)
      pause(5);   // ~0.5 s between refreshes
  }

  exit(0);
}
