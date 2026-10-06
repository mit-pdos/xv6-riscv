#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
sixfive(int n)
{
  if (n % 5 == 0 || n % 6 == 0)
    return 1;

  return 0;
}

int
main(int argc, char *argv[])
{
  int fd;

  if (argc < 2) {
    printf("usage: sixfive filename\n");
    exit(1);
  }

  fd = open(argv[1], O_RDONLY);

  if (fd < 0) {
    printf("sixfive: cannot open %s\n", argv[1]);
    exit(1);
  }

  char c;
  int num = 0;
  int in_num = 0;

  while (read(fd, &c, 1) == 1) {

    if (c >= '0' && c <= '9') {
      num = num * 10 + (c - '0');
      in_num = 1;
    }

    else if (c == ' ' || c == '\n' || c == '\t' || c == '-') {
      if (in_num) {
        if (sixfive(num))
          printf("%d\n", num);

        num = 0;
        in_num = 0;
      }
    }
  }

  if (in_num && sixfive(num))
    printf("%d\n", num);

  close(fd);
  exit(0);
}
