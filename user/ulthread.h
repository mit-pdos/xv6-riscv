#ifndef __UTHREAD_H__
#define __UTHREAD_H__

#include <stdbool.h>

#define MAXULTHREADS 100

enum ulthread_state {
  FREE,
  RUNNABLE,
  YIELD,
};

enum ulthread_scheduling_algorithm {
  ROUNDROBIN,   
  PRIORITY,     
  FCFS,         // first-come-first serve
};

struct ulthread_context {
  uint64 ra;
  uint64 sp;
  // callee-saved
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
  uint64 a0;
  uint64 a1;
  uint64 a2;
  uint64 a3;
  uint64 a4;
  uint64 a5;
};

struct ulthread {
  int tid;                     // Thread ID
  enum ulthread_state state;   // User-level thread state
  uint64 *stack;               // Virtual address of stack
  struct ulthread_context context; // swtch() here to run thread
  uint64 *start_func;           // The start function of the thread
  char name[16];               // Thread name (debugging)
  int priority;                // Priority of the thread
  int created_at;              // Thread creation time for FCFS
};

struct ulthread_list {
  int total;                  // total number of threads currently
  int current;                // index of the current thread
  int yield_tid;              // keep track of the thread that is yielding
  struct ulthread threads[MAXULTHREADS]; // array of threads
  enum ulthread_scheduling_algorithm algorithm; // The scheduling algorithm to use
};

#endif