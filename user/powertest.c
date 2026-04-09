// user/powertest.c
//
// Feature 2: CPU Power States — User-Space Test Program
//
// Purpose:
//   This program exercises the three power states by spawning different
//   numbers of CPU-bound worker processes and waiting long enough for the
//   kernel's update_power_state() to detect the change and print a debug line.
//
// How to run inside xv6:
//   $ powertest
//
// What to observe:
//   Watch the console output for lines beginning with [powerstate].
//   Example expected output (interleaved with normal output):
//     [powerstate] LOW      (runnable=1, timeslice=1)   <- boot
//     [powerstate] BALANCED (runnable=3, timeslice=2)   <- after phase 1
//     [powerstate] HIGH     (runnable=5, timeslice=4)   <- after phase 2
//     [powerstate] LOW      (runnable=1, timeslice=1)   <- after cleanup
//
// Testing plan:
//   Phase 0: just this process -> expect LOW  (0-1 runnable)
//   Phase 1: fork 2 spinners  -> expect BALANCED (3 total: this + 2)
//   Phase 2: fork 4 spinners  -> expect HIGH (5 total: this + 4)
//   Phase 3: all children exit -> expect LOW again
//
// Note: The kernel checks power state every 8 ticks, so there may be a
// short delay (~0.8 s) before a transition is printed to the console.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// spin_loops: a tight CPU spin that runs for approximately 'duration' ticks.
// xv6's tick rate is ~10 ticks/second, so duration=20 => ~2 seconds.
// The loop count is chosen to be large enough to outlast a single timeslice.
#define SPIN_LOOPS 50000000

// phase_delay: spin this process for N ticks to give the kernel time to
// detect the new runnable count and print a state-change message.
static void
phase_delay(void)
{
  volatile int i;
  for(i = 0; i < SPIN_LOOPS; i++)
    ; // Burn CPU; the kernel timer interrupt will fire repeatedly here.
}

int
main(void)
{
  int pids[4];
  int n, i;

  printf("powertest: starting\n");
  printf("powertest: Phase 0 — 1 process running (expect LOW state)\n");

  // Give time for the kernel to observe only 1 runnable process.
  phase_delay();

  // ------------------------------------------------------------------
  // Phase 1: spawn 2 child processes => 3 total RUNNABLE => BALANCED
  // ------------------------------------------------------------------
  printf("powertest: Phase 1 — forking 2 children (expect BALANCED state)\n");
  n = 2;
  for(i = 0; i < n; i++) {
    pids[i] = fork();
    if(pids[i] == 0) {
      // Child: spin for a while, then exit.
      phase_delay();
      exit(0);
    }
    if(pids[i] < 0) {
      printf("powertest: fork failed\n");
      exit(1);
    }
  }
  // Parent also spins so all three processes are runnable together.
  phase_delay();

  // Wait for the Phase 1 children to exit.
  for(i = 0; i < n; i++)
    wait(0);

  printf("powertest: Phase 1 children done\n");

  // Give system time to see fewer runnables.
  phase_delay();

  // ------------------------------------------------------------------
  // Phase 2: spawn 4 child processes => 5 total RUNNABLE => HIGH
  // ------------------------------------------------------------------
  printf("powertest: Phase 2 — forking 4 children (expect HIGH state)\n");
  n = 4;
  for(i = 0; i < n; i++) {
    pids[i] = fork();
    if(pids[i] == 0) {
      phase_delay();
      exit(0);
    }
    if(pids[i] < 0) {
      printf("powertest: fork failed\n");
      exit(1);
    }
  }
  // Parent spins along with the children.
  phase_delay();

  // Wait for Phase 2 children.
  for(i = 0; i < n; i++)
    wait(0);

  printf("powertest: Phase 2 children done\n");

  // ------------------------------------------------------------------
  // Phase 3: back to 1 process => LOW state
  // ------------------------------------------------------------------
  printf("powertest: Phase 3 — all children exited (expect LOW state)\n");
  phase_delay();

  printf("powertest: done\n");
  exit(0);
}
