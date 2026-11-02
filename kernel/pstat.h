#ifndef PSTAT_H
#define PSTAT_H

struct pstat {
  int pid;
  int arrival;
  int first_run;
  int etime;
  int run_ticks;
  int runnable_ticks;
  int sleep_ticks;
  int sched_count;
};

#endif