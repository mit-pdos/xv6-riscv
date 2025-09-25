#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  printf("Mi pid=%d, ppid=%d\n", getpid(), getppid());
  exit(0);
}
