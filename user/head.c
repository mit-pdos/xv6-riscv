#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

void
head(int fd, int nlines)
{
  int n;
  int lines = 0;
  char buf[512];
  int end;

  while (lines < nlines) {
    n = read(fd, buf, 512);
    end = n;
    if (n < 0) {
      printf("read error");
      exit(1);
    }
    if (n == 0) {
      printf("\nEnd of file\n");
      return;
    }
    for (int i = 0; i < n; i++) {
      if (buf[i] == '\n')
        lines++;

      if (lines == nlines) {
        end = i;
        break;
      }
    }
    int wn = write(1, buf, end + 1);
    if (wn < 0) {
      printf("Write error");
      exit(1);
    }
  }
}

int
main(int argc, char *argv[])
{
  int fd, nlines;

  if (argc != 3) {
    printf("Usage: head <filename> <n>\n");
    exit(1);
  }

  nlines = atoi(argv[2]);
  if (nlines <= 0) {
    printf("head: invalid line count %s\n", argv[2]);
    exit(1);
  }

  fd = open(argv[1], O_RDONLY);
  if (fd < 0) {
    printf("head: cannot open %s\n", argv[1]);
    exit(1);
  }

  head(fd, nlines);
  close(fd);
  exit(0);
}
