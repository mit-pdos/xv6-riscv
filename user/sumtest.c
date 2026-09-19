
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if (argc != 3) {
    exit(1);
  }
  int a = atoi(argv[1]);
  int b = atoi(argv[2]);
  printf("sum(%d, %d) = %d\n", a, b, sum(a, b));
  exit(0);
}
