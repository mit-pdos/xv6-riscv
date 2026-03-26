// kernel/powerstate.h
//
// Feature 2: CPU Power States (Dynamic Timeslice Scaling)
//
// This header defines the global power state system for the xv6 kernel.
// The OS tracks how many processes are currently runnable and adjusts
// the CPU timeslice accordingly to balance energy use and throughput.
//
// Power state levels:
//   POWER_LOW      : 0-1 runnable  -> timeslice = 1 tick  (save energy)
//   POWER_BALANCED : 2-3 runnable  -> timeslice = 2 ticks (moderate load)
//   POWER_HIGH     : 4+ runnable   -> timeslice = 4 ticks (max throughput)
//
// How this connects to Feature 1 (SJF):
//   Feature 1 can later use get_timeslice_for_state() as the budget for
//   a process. Instead of yielding here after the threshold, it would
//   trigger a preemption check and pick the shortest-job next.
//
// Energy-aware design rationale:
//   When the system is idle (few processes), a short timeslice means
//   the CPU returns to the scheduler loop faster, enabling it to enter
//   a low-power wait (wfi) sooner. Under high load, a longer timeslice
//   reduces context-switch overhead and maximises CPU utilisation.

#ifndef POWERSTATE_H
#define POWERSTATE_H

// ---------------------------------------------------------------------------
// Power state enum
// Represents the three levels of CPU activity the OS recognises.
// ---------------------------------------------------------------------------
enum power_state {
  POWER_LOW      = 0,  // Low load:  0-1 runnable processes
  POWER_BALANCED = 1,  // Moderate:  2-3 runnable processes
  POWER_HIGH     = 2,  // High load: 4+ runnable processes
};

// ---------------------------------------------------------------------------
// Global current power state
// Updated periodically by update_power_state().
// Read by trap.c to decide the timeslice threshold.
// Declared here; defined in powerstate.c.
// ---------------------------------------------------------------------------
extern enum power_state current_power_state;

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

// count_runnable_procs: scan the process table and return the number of
// processes that are RUNNABLE or RUNNING.
// Called by update_power_state().
int count_runnable_procs(void);

// update_power_state: recount RUNNABLE processes and transition
// current_power_state if the load level has changed.
// Prints a debug message on every state transition.
// Should be called periodically from the timer interrupt path.
void update_power_state(void);

// get_timeslice_for_state: return the timeslice (in ticks) that corresponds
// to the current power state.
// Returns: 1 (LOW), 2 (BALANCED), or 4 (HIGH).
// Used by trap.c to decide when to preempt the running process.
int get_timeslice_for_state(void);

// power_state_name: return a human-readable string for the current state.
// Used only in debug output; not performance-critical.
char *power_state_name(void);

#endif // POWERSTATE_H
