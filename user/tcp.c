#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "kernel/include/net/netutil.h"
#include "user/user.h"

uint32 get_ip(char *ip) {
  int len = strlen(ip);
  int b = 0;
  uint32 res = 0;
  for (int i = 0; i < len; i++) {
    if (ip[i] == '.') {
      res <<= 8;
      res += b;
      b = 0;
    } else {
      if('0' <= ip[i] && ip[i] <= '9')
        b = b*10 + ip[i] - '0'; 
      else
        return 0;
    }
  }
  return res;
}

int
main(int argc, char **argv)
{
  if (argc < 3) {
    printf("usage: %s ip port");
    exit(1);
  }
  uint32 raddr = get_ip(argv[1]);
  uint16 sport = 26001;
  uint16 dport = atoi(argv[2]);
  int sock;

  sock = socket(raddr, sport, dport, SOCK_TCP);

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
