#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int fd = mutex();
  if (fd < 0) { printf("mutex failed\n"); exit(1); }
  printf("fd = %d\n", fd);

  mutex_lock(fd);
  int pid = fork();
  if (pid == 0) {
    // потомок должен ждать пока родитель не отпустит
    mutex_lock(fd);
    printf("child got mutex\n");
    mutex_unlock(fd);
    close(fd);
    exit(0);
  }
  printf("parent unlocks\n");
  mutex_unlock(fd);
  wait(0);
  close(fd);
  exit(0);
}
