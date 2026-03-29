#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    fprintf(2, "usage: sleep seconds\n");
    exit(1);
  }
  i = atoi(argv[1]);
  if(i < 0)
    i = 0;
  pause(i * 100);
  exit(0);
}
