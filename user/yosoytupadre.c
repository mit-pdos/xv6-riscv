#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  int pid  = getpid();
  int ppid = getppid();

  printf("yosoytupadre: pid=%d, ppid=%d\n", pid, ppid);
  exit(0);
}
