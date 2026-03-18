#ifndef _PROCINFO_H_
#define _PROCINFO_H_

#define PROC_NAME_MAX 16

struct procinfo {
  int pid;
  char name[PROC_NAME_MAX];
  int state;
  int ppid;
  char pname[PROC_NAME_MAX];
};

#define PI_UNUSED   0
#define PI_USED     1
#define PI_SLEEPING 2
#define PI_RUNNABLE 3
#define PI_RUNNING  4
#define PI_ZOMBIE   5

#endif