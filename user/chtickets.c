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
    int digit;

    if (*s < '0' || *s > '9')
      return -1;
    digit = *s - '0';
    if (n > (2147483647 - digit) / 10)
      return -1;
    n = n * 10 + digit;
    s++;
  }

  *out = neg ? -n : n;
  return 0;
}

int
main(int argc, char *argv[])
{
  int pid;
  int number;

  if (argc != 3) {
    fprintf(2, "usage: chtickets pid number\n");
    exit(1);
  }

  if (parseint(argv[1], &pid) < 0 || parseint(argv[2], &number) < 0) {
    fprintf(2, "usage: chtickets pid number\n");
    exit(1);
  }

  if (pid <= 0) {
    fprintf(2, "chtickets: pid must be positive\n");
    exit(1);
  }

  if (number <= 0) {
    fprintf(2, "chtickets: number must be positive\n");
    exit(1);
  }

  if (settickets(pid, number) < 0) {
    fprintf(2, "chtickets: failed to set tickets for pid %d\n", pid);
    exit(1);
  }

  exit(0);
}
