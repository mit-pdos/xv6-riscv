#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  int pid1, pid2;

  printf("=== MLFQ Scheduler Test ===\n");
  printf("Parent pid=%d starting at queue %d\n", getpid(), getprio());

  // Fork CPU-bound child — never blocks, MLFQ demotes to queue 2
  pid1 = fork();
  if(pid1 == 0){
    printf("CPU-bound  pid=%d started at queue %d\n", getpid(), getprio());
    volatile long i = 0;
    int last_prio = -1;
    for(i = 0; i < 500000000L; i++){
      // Report every time priority changes
      if(i % 50000000L == 0){
        int prio = getprio();
        if(prio != last_prio){
          printf("CPU-bound  pid=%d moved to queue %d (i=%ld)\n", getpid(), prio, i);
          last_prio = prio;
        }
      }
    }
    printf("CPU-bound  pid=%d done at queue %d\n", getpid(), getprio());
    exit(0);
  }

  // Fork I/O-bound child — blocks often, MLFQ keeps in queue 0
  pid2 = fork();
  if(pid2 == 0){
    printf("I/O-bound  pid=%d started at queue %d\n", getpid(), getprio());
    for(int j = 0; j < 5; j++){
      pause(5);   // blocks voluntarily — stays in high priority queue
      printf("I/O-bound  pid=%d woke up iter %d at queue %d\n", getpid(), j, getprio());
    }
    printf("I/O-bound  pid=%d done at queue %d\n", getpid(), getprio());
    exit(0);
  }

  (void)pid1;
  (void)pid2;
  wait(0);
  wait(0);
  printf("=== MLFQ Test complete ===\n");
  exit(0);
}
