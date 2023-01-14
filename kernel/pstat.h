#ifndef _PSTAT_H_

#define _PSTAT_H_

#include "param.h"

struct pstat {

    int pid[NPROC]; // the process ID of each process

    int inuse[NPROC]; // whether this slot of the process table is being used (1 or 0)

    int tickets_original[NPROC]; // the number of tickets each process  originally had

    int tickets_current[NPROC]; // the number of tickets each process currently has

    int time_slices[NPROC]; // the number of time slices each process has been scheduled

};

#endif // _PSTAT_H_
