#ifndef _PSTAT_H_
#define _PSTAT_H_
// Source: 
// https://github.com/remzi-arpacidusseau/ostep-projects/tree/master/scheduling-xv6-lottery

#include "param.h"
#include "types.h"

struct pstat {
  int inuse[NPROC];   // whether this slot of the process table is in use (1 or 0)
  int tickets[NPROC]; // the number of tickets this process has
  int pid[NPROC];     // the PID of each process 
  uint ticks[NPROC];   // the number of ticks each process has accumulated 
};

#endif // _PSTAT_H_
