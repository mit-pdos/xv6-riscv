#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
noOfLines(int fd)
{
  char ch;
  int n;
  int lines = 0;
  char last='x';
  while (1) {
    n = read(fd, &ch, 1);
    if (n < 0) {
      printf("read failed");
      exit(1);
    }
    if (n == 0) {
      break;
    }
    if (ch == '\n')
    {
      lines++;
    }
    last=ch;
  }
  if(last!='\n')
   lines++;
  return lines;
}
void
tail(int fd, int nlines,int tlines)
{
  int cline = 1;
  char ch;
  int n;
  while (1) {
    n = read(fd, &ch, 1);
    if (n < 0) {
      printf("read failed");
      exit(1);
    }
    if (n == 0) {
      break;
    }
    if (ch == '\n')
      cline++;

    if (cline > (tlines - nlines))
      write(1, &ch, 1);
  }
}
int
main(int argc, char *argv[])
{
  int fd, nlines;

  if (argc != 3) {
    printf("Usage: tail <filename> <n>\n");
    exit(1);
  }

  nlines = atoi(argv[2]);
  if (nlines <= 0) {
    printf("tail: invalid line count %s\n", argv[2]);
    exit(1);
  }

  fd = open(argv[1], O_RDONLY);

  if (fd < 0) {
    printf("tail: cannot open %s\n", argv[1]);
    exit(1);
  }
  int tlines=noOfLines(fd);
  close(fd);
  fd = open(argv[1], O_RDONLY);
  tail(fd, nlines,tlines);
  close(fd);
  exit(0);
}