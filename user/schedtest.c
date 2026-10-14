#include "kernel/types.h"
#include "user/user.h"

#define NCHILD 3
#define WORK 200000000

struct result {
  int pid;
  int priority;
  int first;
  int finish;
};

void
worker(int priority, int readfd, int writefd)
{
  char signal;
  volatile unsigned long total = 0;
  struct result r;

  if(setpriority(priority) < 0)
    exit(1);

  if(read(readfd, &signal, 1) != 1)
    exit(1);

  close(readfd);

  r.pid = getpid();
  r.priority = priority;
  r.first = uptime();

  printf("START pid=%d priority=%d\n",
         r.pid, r.priority);

  for(int i = 0; i < WORK; i++)
    total += i % 7;

  r.finish = uptime();

  printf("FINISH pid=%d priority=%d\n",
         r.pid, r.priority);

  write(writefd, &r, sizeof(r));
  close(writefd);
  exit(0);
}

int
main(void)
{
  int priorities[NCHILD] = {10, 30, 20};
  int startpipes[NCHILD][2];
  int resultpipes[NCHILD][2];
  struct result r;
  int turnaround_total = 0;
  int response_total = 0;

  printf("Starting aging scheduler test\n");

  for(int i = 0; i < NCHILD; i++) {
    if(pipe(startpipes[i]) < 0 ||
       pipe(resultpipes[i]) < 0)
      exit(1);

    int pid = fork();

    if(pid < 0)
      exit(1);

    if(pid == 0) {
      close(startpipes[i][1]);
      close(resultpipes[i][0]);

      worker(priorities[i],
             startpipes[i][0],
             resultpipes[i][1]);
    }

    close(startpipes[i][0]);
    close(resultpipes[i][1]);
  }

  pause(20);

  int release = uptime();

  printf("Releasing all processes\n");

  for(int i = 0; i < NCHILD; i++) {
    write(startpipes[i][1], "X", 1);
    close(startpipes[i][1]);
  }

  for(int i = 0; i < NCHILD; i++) {
    if(read(resultpipes[i][0], &r,
            sizeof(r)) != sizeof(r)) {
      printf("Failed to read result\n");
      exit(1);
    }

    int turnaround = r.finish - release;
    int response = r.first - release;

    turnaround_total += turnaround;
    response_total += response;

    printf("PID %d priority %d turnaround %d response %d\n",
           r.pid, r.priority, turnaround, response);

    close(resultpipes[i][0]);
  }

  for(int i = 0; i < NCHILD; i++)
    wait(0);

  printf("Average turnaround: %d ticks\n",
         turnaround_total / NCHILD);

  printf("Average response: %d ticks\n",
         response_total / NCHILD);

  exit(0);
}
