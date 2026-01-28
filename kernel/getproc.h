#ifndef GETPROC_H
#define GETPROC_H

// Process states for user space (must match kernel procstate enum)
enum procstate_info { P_UNUSED, P_USED, P_SLEEPING, P_RUNNABLE, P_RUNNING, P_ZOMBIE };

// Structure to hold process information for user space
struct procinfo {
  int pid;                    // Process ID
  enum procstate_info state;  // Process state
  uint64 sz;                  // Size of process memory (bytes)
  char name[16];              // Process name
};

#endif
