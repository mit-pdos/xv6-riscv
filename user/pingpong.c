#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  int pid;
  int p[2];

  pipe(p);
  pid = fork();
  if(pid == 0) {
    char b[5];
    while(read(p[0], &b, sizeof(b)) <= 0);
    fprintf(2, "%d: received %s\n", getpid(), b);
    while(write(p[1], "pong", 5) <= 0);
  } else if(pid > 0) {
    char b[5];
    while(write(p[1], "ping", 5) <= 0);
    while(read(p[0], &b, sizeof(b)) <= 0);
    fprintf(2, "%d: received %s\n", getpid(), b);
  } else {
    fprintf(2, "fork error occured\n");
    exit(1);
  }

  close(p[0]);
  close(p[1]);

  exit(0);
}
