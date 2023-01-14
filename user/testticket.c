#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if (argc != 2) {
    fprintf(2, "Usage: %s ticket_count\n", argv[0]);
    exit(1);
  }

  int tc = atoi(argv[1]);
  if (settickets(tc) < 0) {
    fprintf(2, "settickets sys_call failed\n");
    exit(1);
  }

  while (1) ;

  exit(0);
}
