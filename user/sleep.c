#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  if (argc != 2) {
    fprintf(2, "usage: sleep <ticks>\n");
    exit(1);
  }
  pause(atoi(argv[1]));
  exit(0);
}
