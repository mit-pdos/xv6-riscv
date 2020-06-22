#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  uint32 raddr = 0x0a000202;
  uint16 lport = 26999;
  uint16 rport = 2000;
  int sock;

  sock = socket(raddr, lport, rport);

  while(1) {
    char rbuf[256];
    char wbuf[256];

    int wsize = read(1, wbuf, 256);
    write(sock, wbuf, wsize);

    read(sock, rbuf, 256);
    printf("%s", rbuf);
  }

  close(sock);
  exit(0);
}

