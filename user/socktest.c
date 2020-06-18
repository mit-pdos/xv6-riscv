#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  uint32 raddr = 0x0a000202;
  uint16 lport = 26990;
  uint16 rport = 1991;
  int sock[100];

  for(int i = 0; i < 10; i++) {
    sock[i] = socket(raddr, lport+i, rport+i);
    write(sock[i], "testdayo-n\n", 12);
    printf("sock[%d]=%d, lport: %d, rport: %d\n", i, sock[i], lport+i, rport+i);
  }

  for(int i = 0; i < 10; i++) 
    close(sock[i]);

  exit(0);
}

