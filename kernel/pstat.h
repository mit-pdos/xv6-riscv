#ifndef _PSTAT_H_
#define _PSTAT_H_

#include "param.h"

struct pstat {
  int inuse[NPROC];        // Whether this slot is in use (1 or 0)
  int pid[NPROC];          // PID of each process
  int ppid[NPROC];         // Parent PID of each process
  char name[NPROC][16];    // Name of each process
  int priority[NPROC];     // Current priority level (0-3)
  char state[NPROC][10];   // State as string
  uint64 sz[NPROC];        // Size of process memory
  int ticks[NPROC];        // Ticks used at current priority
  int wait_ticks[NPROC];   // Ticks waiting in current queue
};

#endif // _PSTAT_H_