#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc != 2){
    fprintf(2, "usage: hibernate pid\n");
    exit(1);
  }

  if(hibernate(atoi(argv[1])) < 0){
    fprintf(2, "hibernate: failed for pid %s\n", argv[1]);
    exit(1);
  }

  exit(0);
}
