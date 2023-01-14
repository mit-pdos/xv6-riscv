#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int tc;

  if(argc != 2){
    fprintf(2, "Usage: %s ticket_count\n", argv[0]);
    exit(1);
  }

  tc = atoi(argv[1]);
  settickets(tc);

  exit(0);
}
