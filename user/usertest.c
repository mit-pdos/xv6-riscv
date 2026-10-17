#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int fd = mutex();
  if (fd < 0) { printf("mutex failed\n"); exit(1); }
  printf("fd = %d\n", fd);

  mutex_lock(fd);
  int pid = fork();
  if (pid == 0) {
    mutex_lock(fd);
    printf("1\n");
    mutex_unlock(fd);
    close(fd);
    exit(0);
  }

  mutex_unlock(fd);
  wait(0);
  close(fd);
  exit(0);
}
