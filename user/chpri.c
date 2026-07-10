#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static int
parseint(char *s, int *out)
{
  int neg = 0;
  int n = 0;

  if (*s == '-') {
    neg = 1;
    s++;
  }

  if (*s == '\0')
    return -1;

  while (*s) {
    if (*s < '0' || *s > '9')
      return -1;
    n = n * 10 + *s - '0';
    s++;
  }

  *out = neg ? -n : n;
  return 0;
}

int
main(int argc, char *argv[])
{
  int pid;
  int priority;

  if (argc != 3) {
    fprintf(2, "usage: chpri pid priority\n");
    exit(1);
  }

  if (parseint(argv[1], &pid) < 0 || parseint(argv[2], &priority) < 0) {
    fprintf(2, "usage: chpri pid priority\n");
    exit(1);
  }

  if (pid <= 0) {
    fprintf(2, "chpri: pid must be positive\n");
    exit(1);
  }

  if (priority < 0 || priority > 100) {
    fprintf(2, "chpri: priority must be between 0 and 100\n");
    exit(1);
  }

  if (setpriority(pid, priority) < 0) {
    fprintf(2, "chpri: failed to set priority for pid %d\n", pid);
    exit(1);
  }

  exit(0);
}
