
#define MAXPROC 64   // ίδιο με NPROC kernel

struct pstat {
  int pid[MAXPROC];
  int ppid[MAXPROC];
  int priority[MAXPROC];
  int state[MAXPROC];
  int size[MAXPROC];
  char name[MAXPROC][16];
};
