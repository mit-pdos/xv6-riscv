#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

static int
hexval(char c)
{
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  return -1;
}

int
main(int argc, char* argv[])
{
  char* hex, * name;
  int fd, len, nbytes;
  uchar* buf;
  

  if (argc != 3) {
    fprintf(2, "usage: hexwrite HEX file\n");
    exit(1);
  }

  hex = argv[1];
  name = argv[2];
  len = strlen(hex);

  if (len % 2 != 0) {
    fprintf(2, "hexwrite: odd hex string length\n");
    exit(1);
  }

  nbytes = len / 2;
  buf = malloc(nbytes);
  if (buf == 0) {
    fprintf(2, "hexwrite: no memory\n");
    exit(1);
  }

  for (int i = 0; i < nbytes; i++) {
    int hi = hexval(hex[2 * i]);
    int lo = hexval(hex[2 * i + 1]);
    if (hi < 0 || lo < 0) {
      fprintf(2, "hexwrite: bad hex string\n");
      free(buf);
      exit(1);
    }
    buf[i] = (hi << 4) | lo;
  }

  fd = open(name, O_WRONLY);
  if (fd < 0) {
    fprintf(2, "hexwrite: cannot open %s\n", name);
    free(buf);
    exit(1);
  }

  int r = write(fd, buf, nbytes);
  if (r != nbytes) {
    fprintf(2, "Write error\n");
    free(buf);
    close(fd);
    exit(1);
  }

  free(buf);
  close(fd);
  exit(0);
}