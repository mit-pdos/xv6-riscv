#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  if (vmprint() < 0) {
    fprintf(2, "vmprint: system call failed\n");
    exit(1);
  }

  exit(0);
}
