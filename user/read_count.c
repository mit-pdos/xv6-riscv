#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int count = getreadcount();
  printf("Read count: %d\n", count);
  exit(0);
}
