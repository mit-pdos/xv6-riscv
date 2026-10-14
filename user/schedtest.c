#include "kernel/types.h"
#include "user/user.h"

#define WORK 30000000

void
worker(int priority, int readfd)
{
  char signal;
  volatile unsigned long total = 0;

  if(setpriority(priority) < 0) {
    printf("Failed to set priority %d\n", priority);
    exit(1);
  }

  printf("READY pid=%d priority=%d\n",
         getpid(), getpriority());

  // Wait until the parent releases all children.
  if(read(readfd, &signal, 1) != 1) {
    printf("Failed to receive start signal\n");
    exit(1);
  }

  close(readfd);

  printf("START pid=%d priority=%d\n",
         getpid(), getpriority());

  for(int i = 0; i < WORK; i++)
    total += i % 7;

  printf("FINISH pid=%d priority=%d\n",
         getpid(), getpriority());

  exit(0);
}

int
main(void)
{
  int priorities[] = {10, 30, 20};
  int pipes[3][2];
  int pid;

  printf("Starting synchronized scheduler test\n");

  for(int i = 0; i < 3; i++) {
    if(pipe(pipes[i]) < 0) {
      printf("Pipe creation failed\n");
      exit(1);
    }

    pid = fork();

    if(pid < 0) {
      printf("Fork failed\n");
      exit(1);
    }

    if(pid == 0) {
      close(pipes[i][1]);
      worker(priorities[i], pipes[i][0]);
    }

    close(pipes[i][0]);
  }

  // Allow children time to set their priorities.
  pause(20);

  printf("Releasing all processes\n");

  for(int i = 0; i < 3; i++) {
    write(pipes[i][1], "X", 1);
    close(pipes[i][1]);
  }

  for(int i = 0; i < 3; i++)
    wait(0);

  printf("Scheduler test completed\n");
  exit(0);
}
