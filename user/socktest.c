#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  uint32 raddr = 0x0a000202;
  uint16 lport = 26999;
  uint16 rport = 2000;
  int sock = socket(raddr, lport, rport);
  printf("raddr: %x, lport: %d, rport: %d\n", raddr, lport, rport);
  printf("sock: %d\n", sock);

  char test[] = "testdayo-n\n";
  write(sock, test, strlen(test));
  exit(0);
}

