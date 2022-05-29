#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define N  1000

int main(void) {
  int fd = open("buffer", O_RDONLY);
  int sid = semget(23, 1);
  for (;;) {
    char buffer[7];
    if (semdown(sid) == 0) {
      printf("CONS IN \n");
      timeout(10000);
      read(fd, &buffer, sizeof buffer);
      printf("CONS OUT \n");
      timeout(10000);
      semup(sid);
    }
  }
  semclose(sid);
  close(fd);
  exit(0);
}
