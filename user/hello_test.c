#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int n = 42;
  
  printf("Testing hello system call with argument: %d\n", n);
  hello(n);
  
  exit(0);
}
