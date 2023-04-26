#include "../kernel/types.h"
#include "user.h"

int main(int argc, char* argv[]) {
  int n;
  int pipe1[2], pipe2[2];
  pipe(pipe1), pipe(pipe2);
  int pid = fork();
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
  return 0;
}

