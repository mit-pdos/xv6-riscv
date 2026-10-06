#ifndef _PROC_INFO_H_
#define _PROC_INFO_H_

#include "types.h"
#include "procstate.h"

struct procinfo {
	int pid;
	char name[20];
	int ppid;
	enum procstate state;
};

#endif
