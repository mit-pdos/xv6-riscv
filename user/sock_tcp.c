#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "kernel/include/net/netutil.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  uint32 raddr = 0x0a000202;
  uint16 rport = 2001;
  int sock;

  sock = socket(raddr, rport, SOCK_TCP_LISTEN);

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

