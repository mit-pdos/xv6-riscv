#include "kernel/types.h"
#include "user.h"

char buff[10000];

void dmesg_print() {
  int res = dmesg(buff, 10000);
  buff[10000 - 1] = 0;
  printf("dmesg: exited with code %p\n res: %s\n", res, buff);
}

int main(int argc, char* argv[]) {
  int n;
  if (argc != 2) {
    printf("Incorrect arguments\n");
    return -1;
  }
  int pipe1[2], pipe2[2];
  dmesg_print();
  cloglev(6);
  if (pipe(pipe1) < 0 || pipe(pipe2) < 0) {
    printf("Pipe error\n");
    return -1;
  }
  int pid = fork();
  if (pid < 0) {
    printf("Fork error\n");
    return -1;
  }
  char c;
  if (pid != 0) {
    close(pipe1[0]);
    close(pipe2[1]);
    for (uint i = 0; i < strlen(argv[1]); i++) {
      write(pipe1[1], &argv[1][i], 1);
    }
    close(pipe1[1]);
    wait(0);
    while ((n = read(pipe2[0], &c, 1)) > 0) {
      printf("%d: received %c\n", getpid(), c);
    }
  } else {
    close(pipe2[0]);
    close(pipe1[1]);
    while ((n = read(pipe1[0], &c, 1)) > 0) {
      printf("%d: received %c\n", getpid(), c);
      write(pipe2[1], &c, 1);
    }
    close(pipe2[1]);
  }
  cloglev(0);
  dmesg_print();
  return 0;
}

