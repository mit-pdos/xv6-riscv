#pragma once

#include "types.h"

int  argint(int, int*);
int  argstr(int, char*, int);
int  argaddr(int, uint64 *);
int  fetchstr(uint64, char*, int);
int  fetchaddr(uint64, uint64*);
void syscall();
