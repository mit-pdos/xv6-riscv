// Shared by the kernel (sysproc.c) and user programs.
// Fields you have not implemented yet must be left as 0.

#define PS_UNUSED   0  // these must match enum procstate in kernel/proc.h
#define PS_USED     1
#define PS_SLEEPING 2
#define PS_RUNNABLE 3
#define PS_RUNNING  4
#define PS_ZOMBIE   5

#define POLICY_RR   0
#define POLICY_PRIO 1

#define PRIO_HIGH   0
#define PRIO_NORMAL 1
#define PRIO_LOW    2

struct schedinfo {
  int pid;
  int state;      // PS_*
  int nsched;     // Q1: times a scheduler picked this process
  int rticks;     // Q1: timer interrupts while RUNNING
  int lastcpu;    // Q1: hart it last ran on
  int slice;      // Q2: time slice in ticks
  int ctime;      // Q3: ticks when kfork() made it RUNNABLE
  int ftime;      // Q3: ticks when forkret() first ran it
  int firstcpu;   // Q3: hart it first ran on
  int affinity;   // Q4: CPU mask
  int prio;       // Q5: PRIO_*
  char name[16];  // Bonus: process name
};
