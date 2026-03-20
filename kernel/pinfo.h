// Process information structure
// Shared between kernel and user space
struct pinfo {
  int pid;              // Process ID
  int parent_pid;       // Parent process ID
  int state;            // Process state
  uint64 sz;            // Memory size in bytes
  char name[16];        // Process name
};

// Process states (matching kernel/proc.h enum procstate)
#define PSTATE_UNUSED    0
#define PSTATE_USED      1
#define PSTATE_SLEEPING  2
#define PSTATE_RUNNABLE  3
#define PSTATE_RUNNING   4
#define PSTATE_ZOMBIE    5
