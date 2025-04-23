#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "proc.h"

extern int pipe_rt(int*);

uint64 sys_pipe_rt(void) {
  uint64 addr;
  argaddr(0, &addr);

  int fds[2];
  if (pipe_rt(fds) < 0) return -1;

  if (copyout(myproc()->pagetable, addr, (char*)fds, sizeof(fds)) < 0)
    return -1;

  return 0;
}
