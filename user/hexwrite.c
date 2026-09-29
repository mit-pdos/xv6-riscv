#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
hexval(char c)
{
  if (c >= '0' && c <= '9')
    return c - '0';
  if (c >= 'A' && c <= 'F')
    return c - 'A' + 10;
  if (c >= 'a' && c <= 'f')
    return c - 'a' + 10;
  return -1;
}

int
main(int argc, char *argv[])
{
  char buf[128];
  int fd, len, i, hi, lo;

  if (argc != 3) {
    fprintf(2, "usage: hexwrite hexcodes file\n");
    exit(1);
  }
  len = strlen(argv[1]);
  if (len == 0 || len % 2 != 0 || len / 2 > sizeof(buf)) {
    fprintf(2, "hexwrite: bad hex string\n");
    exit(1);
  }
  for (i = 0; i < len / 2; i++) {
    hi = hexval(argv[1][2 * i]);
    lo = hexval(argv[1][2 * i + 1]);
    if (hi < 0 || lo < 0) {
      fprintf(2, "hexwrite: bad hex string\n");
      exit(1);
    }
    buf[i] = hi * 16 + lo;
  }

  fd = open(argv[2], O_WRONLY);
  if (fd < 0) {
    fprintf(2, "hexwrite: cannot open %s\n", argv[2]);
    exit(1);
  }
  if (write(fd, buf, len / 2) != len / 2) {
    printf("Write error\n");
    close(fd);
    exit(1);
  }
  close(fd);
  exit(0);
}
