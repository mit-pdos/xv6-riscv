#ifndef _KERNEL_PS_H_
#define _KERNEL_PS_H_

#define PS_NAME_LEN 16

// Matches enum procstate in proc.h
#define PS_SLEEPING 2
#define PS_RUNNABLE 3
#define PS_RUNNING  4

struct pinfo {
  int pid;
  int state;
  uint64 sz;
  char name[PS_NAME_LEN];
};

#endif
