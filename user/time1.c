#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int t1, t2; 
  int p;

  if(argc < 2){
    fprintf(2, "usage: time1 command\n");

    exit(1);
  }

  t1 = uptime();

  p = fork();

  if(p < 0){
    printf("fork failed!\n");

    exit(1);
  }

  if(p == 0){
    exec(argv[1], &argv[1]);

    printf("exec failed\n");

    exit(1);
  }

  wait(0);

  t2 = uptime();

  printf("elapsed time: %d ticks\n", t2 - t1);

  exit(0);
}
