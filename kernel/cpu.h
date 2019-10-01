#pragma once

#include "context.h"
#include "param.h"
#include "proc.h"

// Per-CPU state.
struct cpu {
  struct proc *proc;          // The process running on this cpu, or null.
  struct context scheduler;   // swtch() here to enter scheduler().
  int noff;                   // Depth of push_off() nesting.
  int intena;                 // Were interrupts enabled before push_off()?
};

extern struct cpu cpus[NCPU];

int             cpuid(void);
struct cpu*     mycpu(void);
