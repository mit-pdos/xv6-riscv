#include "kernel/types.h"
#include "user/user.h"

#define NWORKERS 3
#define WORK 1500000000

void
worker(int priority, int readfd, int start)
{
  char signal;
  volatile unsigned long total = 0;

  if(setpriority(priority) < 0) {
    printf("Failed to set priority %d\n", priority);
    exit(1);
  }

  if(read(readfd, &signal, 1) != 1)
    exit(1);

  close(readfd);

  int first = uptime();

  printf("START pid=%d priority=%d response=%d\n",
         getpid(), priority, first - start);

  for(int j = 0; j < WORK; j++)
    total += j % 7;

  printf("FINISH pid=%d priority=%d turnaround=%d\n",
         getpid(), priority, uptime() - start);

  exit(0);
}

int
main(void)
{
  int priorities[NWORKERS] = {10, 10, 9};
  int pipes[NWORKERS][2];

  printf("Starting aging verification test\n");

  for(int i = 0; i < NWORKERS; i++) {
    if(pipe(pipes[i]) < 0) {
      printf("Pipe creation failed\n");
      exit(1);
    }

    int pid = fork();

    if(pid < 0) {
      printf("Fork failed\n");
      exit(1);
    }

    if(pid == 0) {
      close(pipes[i][1]);
      worker(priorities[i], pipes[i][0], uptime());
      exit(0);
    }

    close(pipes[i][0]);
  }


  printf("Releasing all workers\n");

  for(int i = 0; i < NWORKERS; i++) {
    write(pipes[i][1], "x", 1);
    close(pipes[i][1]);
  }

  for(int i = 0; i < NWORKERS; i++)
    wait(0);

  printf("Aging verification completed\n");
  exit(0);
}
