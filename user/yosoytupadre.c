#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = getpid();
  int ppid = getppid();
  printf("Mi PID: %d, Mi padre: %d\n", pid, ppid);

  for (int i = 0; i < 4; i++) {
    int anc = getancestor(i);
    printf("getancestor(%d) = %d\n", i, anc);
  }

  exit(0);
}
