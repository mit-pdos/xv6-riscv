#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
main()
{
  printf("\033[2J\033[H");
  return 0;
}
