#include "kernel/types.h"
#include "kernel/pstat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int t1, t2;
  int p;
  int elapsed;
  int percent;
  struct rusage r;

  if (argc < 2) {
    fprintf(2, "usage: time command\n");
    exit(1);
  }

  t1 = uptime();

  p = fork();

  if (p < 0) {
    printf("fork failed!\n");
    exit(1);
  }

  if (p == 0) {
    exec(argv[1], &argv[1]);

    printf("exec failed\n");
    exit(1);
  }

  if (wait2(0, &r) < 0) {
    printf("wait2 failed\n");
    exit(1);
  }

  t2 = uptime();

  elapsed = t2 - t1;

  percent = 0;
  if (elapsed > 0)
    percent = (r.cputime * 100) / elapsed;

  printf("elapsed time: %d ticks, cpu time: %d ticks, %d%% CPU\n", elapsed,
         r.cputime, percent);

  exit(0);
}
