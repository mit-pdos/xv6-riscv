#ifndef _PROC_INFO_H_
#define _PROC_INFO_H_

#include "proc.h"
#include "types.h"

struct procinfo {
	int pid;
	char name[20];
	int ppid;
	enum procstate state;
};

#endif

