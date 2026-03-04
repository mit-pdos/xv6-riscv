#include "kernel/param.h"
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int pipefd[2];
  char buf[256];
  int err, nfd, ret, len;
  int buf_end = 0;
  err = pipe(pipefd);
  if (err == -1) {
    fprintf(2, "failed to create pipe\n");
    exit(1);
  }
  int pid = fork();

  switch (pid) {
  case -1:
    fprintf(2, "fork error\n");
    exit(1);
  case 0:
    err = close(pipefd[1]);
    if (err == -1) {
      fprintf(2, "failed to close %d fd\n", pipefd[1]);
      exit(1);
    }

    err = close(0);
    if (err == -1) {
      fprintf(2, "failed to close 0 fd\n");
      exit(1);
    }

    nfd = dup(pipefd[0]);
    if (nfd == -1) {
      fprintf(2, "failed to dup %d fd\n", pipefd[0]);
      exit(1);
    }

    err = close(pipefd[0]);
    if (err == -1) {
      fprintf(2, "failed to close %d fd\n", pipefd[0]);
      exit(1);
    }

    char *nargv[] = {"/wc", 0};

    exec("/wc", nargv);

    fprintf(2, "exec failed\n");
    exit(1);
  default:
    err = close(pipefd[0]);
    if (err == -1) {
      fprintf(2, "failed to close %d fd\n", pipefd[0]);
      exit(1);
    }

    for (int i = 1; i < argc; ++i) {
      int arg_len = strlen(argv[i]);
      if (buf_end + arg_len + 1 > sizeof(buf)) {
        fprintf(2, "to many arguments\n");
        exit(1);
      }

      strcpy(buf + buf_end, argv[i]);
      buf_end += arg_len;
      buf[buf_end++] = '\n';
    }

    char *ptr = buf;
    len = buf_end;
    while (len > 0) {
      ret = write(pipefd[1], ptr, len);
      if (ret < 0) {
        fprintf(2, "failed to write to pipe: %d\n", pipefd[1]);
        exit(1);
      }
      ptr += ret;
      len -= ret;
    }

    err = close(pipefd[1]);
    if (err == -1) {
      fprintf(2, "failed to close %d fd\n", pipefd[1]);
      exit(1);
    }

    int status;
    int child_id = wait(&status);
    (void)child_id;
    exit(0);
  }
}
