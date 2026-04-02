#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc != 2){
    fprintf(2, "usage: suspend pid\n");
    exit(1);
  }

  if(suspend(atoi(argv[1])) < 0){
    fprintf(2, "suspend: failed for pid %s\n", argv[1]);
    exit(1);
  }

  exit(0);
}
