#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int ticks = uptime();
  fprintf(1, "%d\n", ticks);
  exit(0);
}
