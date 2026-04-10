// kernel/powerstate.c
//
// Feature 2: CPU Power States (Dynamic Timeslice Scaling)
//
// This file implements the energy-aware power state subsystem.
// It tracks the number of runnable processes and automatically adjusts
// the CPU timeslice to balance responsiveness with energy efficiency.
//
// Control flow:
//   1. clockintr() fires (every ~0.1 s in xv6)
//   2. usertrap() / kerneltrap() detect a timer interrupt (which_dev == 2)
//   3. trap.c increments p->ticks_in_slice and calls update_power_state()
//      periodically to refresh the global state.
//   4. trap.c reads get_timeslice_for_state() and yields only when the
//      process has used its full slice.
//
// Hook point for Feature 1 (SJF):
//   update_power_state() sets the timeslice budget that Feature 1 can use
//   as the preemption window for its shortest-job-first scheduler.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "powerstate.h"

// ---------------------------------------------------------------------------
// Global state
// Initialise to LOW: at boot there are very few (or zero) runnable procs.
// ---------------------------------------------------------------------------
enum power_state current_power_state = POWER_LOW;

// proc[] is the global process table, defined in proc.c.
// We declare it extern here so we can scan it in count_runnable_procs().
// This follows the same xv6 pattern used by other kernel files
// (e.g. "extern char trampoline[]" in trap.c).
extern struct proc proc[];

// ---------------------------------------------------------------------------
// count_runnable_procs
//
// What it does:
//   Scans the entire global process table (proc[]) and counts how many
//   processes are in the RUNNABLE or RUNNING state.
//
// Why we count RUNNING too:
//   A RUNNING process is occupying a CPU right now; it contributes to
//   system load just as much as a RUNNABLE one. Including it gives a more
//   accurate picture of overall demand.
//
// Note on locking:
//   We deliberately do NOT acquire p->lock for each process here.
//   This function is called from a timer interrupt context. Acquiring
//   per-process locks would risk deadlock and add latency. We accept
//   a potentially stale count — this is acceptable for a power-state
//   heuristic that only needs approximate accuracy.
//
// Hook for Feature 1 (SJF):
//   Feature 1's run-queue logic could replace or supplement this scan.
// ---------------------------------------------------------------------------
int
count_runnable_procs(void)
{
  struct proc *p;
  int count = 0;

  // Walk the full process table defined in proc.c.
  // NPROC (from param.h) is the maximum number of processes xv6 supports.
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == RUNNABLE || p->state == RUNNING) {
      count++;
    }
  }
  return count;
}

// ---------------------------------------------------------------------------
// update_power_state
//
// What it does:
//   Calls count_runnable_procs(), computes which power level the system
//   should be in, and updates current_power_state if it has changed.
//   Prints a single-line debug message whenever the state transitions.
//
// Why it exists:
//   The power state is a global property of the system. Updating it here
//   (rather than inside trap.c) keeps the logic centralised and testable.
//
// When to call it:
//   From the timer interrupt path, but NOT on every tick — scanning NPROC
//   entries on every interrupt is wasteful. The caller (trap.c) should
//   call this every N ticks (e.g. every 8 ticks) using a tick modulo check.
//
// Debug output:
//   Prints one line per transition; easy to grep / disable.
//   To disable: comment out the printf lines below.
// ---------------------------------------------------------------------------
void
update_power_state(void)
{
  int n = count_runnable_procs();
  enum power_state new_state;

  // Determine which state is appropriate for the current load.
  if(n <= 1) {
    new_state = POWER_LOW;
  } else if(n <= 3) {
    new_state = POWER_BALANCED;
  } else {
    new_state = POWER_HIGH;
  }

  // Only act (and print) when the state actually changes.
  // This prevents a flood of identical debug messages.
  if(new_state != current_power_state) {
    current_power_state = new_state;

    // Debug: print the transition so it is visible on the QEMU console.
    // Format: [powerstate] <NAME> (runnable=N, timeslice=T)
    // To disable debug output, comment out the next line.
    printf("[powerstate] %s (runnable=%d, timeslice=%d)\n",
           power_state_name(), n, get_timeslice_for_state());
  }
}

// ---------------------------------------------------------------------------
// get_timeslice_for_state
//
// What it does:
//   Returns the number of timer ticks a process is allowed to run before
//   being preempted under the current power state.
//
// Timeslice table:
//   POWER_LOW      -> 1 tick  (fast preemption; system is nearly idle)
//   POWER_BALANCED -> 2 ticks (moderate; balance responsiveness & overhead)
//   POWER_HIGH     -> 4 ticks (longer slices; reduce context-switch cost)
//
// Why it exists:
//   Centralising the lookup here means trap.c never needs to know the
//   raw power state values — it just asks "how long should this slice be?"
//
// Hook for Feature 1 (SJF):
//   Feature 1 can call this to get the maximum budget for a process.
//   SJF would then preempt even earlier if a shorter job becomes runnable.
// ---------------------------------------------------------------------------
int
get_timeslice_for_state(void)
{
  switch(current_power_state) {
  case POWER_LOW:
    return 2;
  case POWER_BALANCED:
    return 5;
  case POWER_HIGH:
    return 10;
  default:
    return 2;  // Safe fallback: behave like LOW if state is undefined.
  }
}

// ---------------------------------------------------------------------------
// power_state_name
//
// What it does:
//   Returns a short human-readable string for the current power state.
//   Used only in debug printf calls; not performance-critical.
// ---------------------------------------------------------------------------
char *
power_state_name(void)
{
  switch(current_power_state) {
  case POWER_LOW:
    return "LOW";
  case POWER_BALANCED:
    return "BALANCED";
  case POWER_HIGH:
    return "HIGH";
  default:
    return "UNKNOWN";
  }
}
