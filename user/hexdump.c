#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

static int
digit2hex(int x)
{
  if (x < 10) return '0' + x;
  return 'A' + (x - 10);
}

int
main(int argc, char* argv[])
{
  int fd, nbytes, i;
  char* name;
  uchar* buf;

  if (argc != 3) {
    fprintf(2, "usage: hexdump n file\n");
    exit(1);
  }

  nbytes = atoi(argv[1]);
  name = argv[2];

  if (nbytes < 0) {
    fprintf(2, "hexdump: bad size\n");
    exit(1);
  }

  fd = open(name, O_RDONLY);
  if (fd < 0) {
    fprintf(2, "hexdump: cannot open %s\n", name);
    exit(1);
  }

  buf = malloc(nbytes);
  if (buf == 0) {
    fprintf(2, "hexdump: no memory\n");
    close(fd);
    exit(1);
  }

  i = read(fd, buf, nbytes);
  if (i < 0) {
    fprintf(2, "Read error\n");
    free(buf);
    close(fd);
    exit(1);
  }

  for (int j = 0; j < i; j++) {
    printf("%c%c", digit2hex((buf[j] >> 4) & 0xF), digit2hex(buf[j] & 0xF));
    if (j + 1 < i)
      printf(" ");
  }
  printf("\n");

  free(buf);
  close(fd);
  exit(0);
}