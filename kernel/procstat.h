// Per-process and system-wide statistics exported to user space.
// This header is shared between kernel code and user programs.
// Include after types.h.

#ifndef PROCSTAT_H
#define PROCSTAT_H

// Per-process statistics snapshot.
struct procstat {
  int    pid;               // Process ID (0 if slot unused)
  char   name[16];          // Process name
  int    state;             // Process state (enum procstate value)
  int    priority;          // Current MLFQ priority level (0 = highest)
  int    behavior_type;     // 0=mixed, 1=io-bound, 2=cpu-bound

  // Timing — all values in timer ticks
  uint   creation_time;     // Tick when process was created
  uint   first_run_time;    // Tick of first CPU dispatch (0 if never run)
  uint   finish_time;       // Tick when process exited (0 if still alive)
  uint   response_time;     // first_run_time - creation_time (0 if never run)
  uint   turnaround_time;   // finish_time - creation_time (0 if still alive)
  uint   total_wait_time;   // Accumulated scheduling wait (RUNNABLE but not RUNNING)
  uint   total_runtime;     // Accumulated CPU time

  // Context switches
  uint   context_switches;  // Per-process context switch count

  // I/O behavior
  uint64 io_count;          // Number of I/O-style sleeps entered
  uint64 voluntary_yields;  // Voluntary CPU yields via yield()
};

// System-wide aggregate statistics snapshot.
struct sysstats {
  uint   total_processes_created;    // Processes ever created since boot
  uint   total_processes_completed;  // Processes that have called exit()
  uint   total_context_switches;     // System-wide context switch total
  uint   total_cpu_time;             // Sum of all process runtimes (ticks)
  uint   elapsed_time;               // Ticks elapsed since kernel boot
  int    active_processes;           // Processes currently in a non-UNUSED state
};

#endif // PROCSTAT_H
