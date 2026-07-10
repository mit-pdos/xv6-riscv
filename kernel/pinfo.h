#ifndef _PINFO_H_
#define _PINFO_H_

#include "param.h"

#define PINFONAME 16

struct pinfo {
  int inuse[NPROC];
  int pid[NPROC];
  int owner[NPROC];
  int priority[NPROC];
  int status[NPROC];
  int tickets[NPROC];
  int runtime[NPROC];
  char name[NPROC][PINFONAME];
};

#endif
