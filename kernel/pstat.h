#define NPROC 64

/*
  a struct that our new syscall will simple fill with all the necessary
  info it needs

*/

struct pstat{
  int num_processes;
  int pid[NPROC]; // process id
  int ppid[NPROC];
  int priority[NPROC];
  int state[NPROC]; // state of the process
  char name[NPROC][16]; //process name
  uint64 size[NPROC];
};
