#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = getpid();
  int e = getenergy(pid);
  printf("pid=%d energy=%d\n", pid, e);
  exit(0);
}