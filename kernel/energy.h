#ifndef ENERGY_H
#define ENERGY_H

#include "param.h"
#include "types.h"

struct energyinfo {
  int inuse;
  int pid;
  int state;
  uint cpu_ticks;
  uint runnable_ticks;
  uint sleep_ticks;
  uint energy_used;
  char name[16];
  uint recent_cpu_ticks;
  int green_class;
  int system_load;
  int simulated_temperature;
};

#endif