#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pipefd[2];
  int pid;

  if (pipe(pipefd) < 0) {
    fprintf(2, "pipe error\n");
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    fprintf(2, "fork error\n");
    close(pipefd[0]);
    close(pipefd[1]);
    exit(1);
  }

  if (pid == 0) {
    if (close(pipefd[1]) < 0) {
      fprintf(2, "child: close pipefd[1] failed\n");
      exit(1);
    }

    if (close(0) < 0) {
      fprintf(2, "child: close stdin failed\n");
      exit(1);
    }

    if (dup(pipefd[0]) < 0) {
      fprintf(2, "child: dup failed\n");
      exit(1);
    }

    if (close(pipefd[0]) < 0) {
      fprintf(2, "child: close pipefd[0] failed\n");
      exit(1);
    }

    char *wc_argv[2];
    wc_argv[0] = "/wc";
    wc_argv[1] = 0;

    exec("/wc", wc_argv);

    fprintf(2, "child: exec failed\n");
    exit(1);
  } else {
    if (close(pipefd[0]) < 0) {
      fprintf(2, "parent: close pipefd[0] failed\n");
      exit(1);
    }

    for (int i = 1; i < argc; i++) {
      if (write(pipefd[1], argv[i], strlen(argv[i])) < 0) {
        fprintf(2, "parent: write arg failed\n");
        exit(1);
      }
      if (write(pipefd[1], "\n", 1) < 0) {
        fprintf(2, "parent: write newline failed\n");
        exit(1);
      }
    }

    if (close(pipefd[1]) < 0) {
      fprintf(2, "parent: close pipefd[1] failed\n");
      exit(1);
    }

    wait(0);
    exit(0);
  }
}
