#pragma once
#include "kernel/param.h"
#include "kernel/spinlock.h"
#include "kernel/riscv.h"
#include "kernel/proc.h"

struct procinfo {
  int pid, ppid;
  char *name;
  char *pname;
  enum procstate state;
};
