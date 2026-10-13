#ifndef _PSTAT_H_
#define _PSTAT_H_

#include "types.h"
#include "procstate.h"

struct pstat {
    int pid;
    enum procstate state;
    uint64 size;
    int ppid;
    int priority;
    char name[16];
};

#endif
