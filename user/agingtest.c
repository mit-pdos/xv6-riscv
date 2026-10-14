#include "kernel/types.h"
#include "user/user.h"

#define NCHILD 3
#define WORK 150000000

int
main(void)
{
  int priorities[NCHILD] = {0, 40, 40};
  int start = uptime();

  printf("Starting aging verification test\n");

  for(int i = 0; i < NCHILD; i++) {
    int pid = fork();

    if(pid < 0) {
      printf("fork failed\n");
      exit(1);
    }

    if(pid == 0) {
      volatile unsigned long total = 0;

      setpriority(priorities[i]);

      int first = uptime();

      printf("START pid=%d priority=%d wait=%d\n",
             getpid(), priorities[i], first - start);

      for(int j = 0; j < WORK; j++)
        total += j % 7;

      printf("FINISH pid=%d priority=%d time=%d\n",
             getpid(), priorities[i], uptime() - start);

      exit(0);
    }

  }

  for(int i = 0; i < NCHILD; i++)
    wait(0);

  printf("Aging verification completed\n");
  exit(0);
}
