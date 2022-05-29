#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(void) {

  int fd = open("buffer", O_CREATE | O_WRONLY);
  int sid = semget(23, 1);
  for (;;) {
    if (semdown(sid) == 0) {
      printf("PROD IN \n");
      timeout(10000);
      write(fd, "product", strlen("product"));
      printf("PROD OUT \n");
      timeout(10000);
      semup(sid);
    }
  }
  semclose(sid);
  close(fd);
  exit(0);
}
