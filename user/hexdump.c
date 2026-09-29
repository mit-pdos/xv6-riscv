#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char digits[] = "0123456789ABCDEF";

int
main(int argc, char *argv[])
{
  char buf[32];
  int fd, n, i, want;
  int total, done;

  if (argc != 3) {
    fprintf(2, "usage: hexdump count file\n");
    exit(1);
  }
  total = atoi(argv[1]);
  fd = open(argv[2], O_RDONLY);
  if (fd < 0) {
    fprintf(2, "hexdump: cannot open %s\n", argv[2]);
    exit(1);
  }

  done = 0;
  while (done < total) {
    want = total - done;
    if (want > sizeof(buf))
      want = sizeof(buf);
    n = read(fd, buf, want);
    if (n < 0) {
      if (done > 0)
        printf("\n");
      fprintf(2, "Read error\n");
      exit(1);
    }
    if (n == 0)
      break;
    for (i = 0; i < n; i++) {
      if (done + i > 0)
        printf(" ");
      printf("%c%c", digits[(buf[i] >> 4) & 0xF], digits[buf[i] & 0xF]);
    }
    done += n;
  }
  printf("\n");
  close(fd);
  exit(0);
}
