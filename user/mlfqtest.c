#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  int pid1, pid2;

  printf("MLFQ Test starting...\n");

  // Fork CPU-bound child — never blocks, MLFQ demotes to queue 2
  pid1 = fork();
  if(pid1 == 0){
    printf("CPU-bound process started (pid=%d)\n", getpid());
    volatile long i = 0;
    for(i = 0; i < 500000000L; i++){
      // busy loop
    }
    printf("CPU-bound process done\n");
    exit(0);
  }

  // Fork I/O-bound child — blocks often, MLFQ keeps in queue 0
  pid2 = fork();
  if(pid2 == 0){
    printf("I/O-bound process started (pid=%d)\n", getpid());
    for(int j = 0; j < 10; j++){
      pause(5);  // blocks voluntarily — stays in high priority queue
      printf("I/O-bound woke up: iteration %d\n", j);
    }
    printf("I/O-bound process done\n");
    exit(0);
  }

  (void)pid1;
  (void)pid2;
  wait(0);
  wait(0);
  printf("MLFQ Test complete.\n");
  exit(0);
}
