#ifndef _UPROC_H_
#define _UPROC_H_
#include "kernel/types.h"

struct uproc {
  int pid;
  int nice;
  int state;
  char name[16];
  uint64 vruntime;
  uint64 weight;
};

#endif
