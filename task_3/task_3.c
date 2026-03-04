#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  int pipefd[2];
  int err = pipe(pipefd);
  if (err == -1) {
    fprintf(stderr, "error creating pipe\n");
    return 1;
  }
  char buf[256];
  int buf_end = 0;

  int pid = fork();

  switch (pid) {
  case -1:
    fprintf(stderr, "fail to create fork\n");
    return 1;
  case 0:
    err = close(pipefd[1]);
    if (err == -1) {
      fprintf(stderr, "fail to close pipefd: %d\n", pipefd[1]);
      return 1;
    }

    err = close(0);
    if (err == -1) {
      fprintf(stderr, "fail to close 0 fd\n");
      return 1;
    }

    int nfd = dup(pipefd[0]);
    if (nfd == -1) {
      fprintf(stderr, "fail to dup fd\n");
      return 1;
    }

    int n;
    while ((n = read(0, buf + buf_end, sizeof(buf) - buf_end)) > 0) {
      buf_end += n;
    }

    err = close(0);
    if (err == -1) {
      fprintf(stderr, "fail to close 0 fd\n");
      return 1;
    }

    if (n < 0) {
      fprintf(stderr, "fail to read from buf\n");
      return 1;
    }

    if (buf_end >= sizeof(buf)) {
      buf_end--;
    }

    buf[buf_end++] = '\0';
    printf("%s\n", buf);

    return 0;

  default:
    err = close(pipefd[0]);
    if (err == -1) {
      fprintf(stderr, "failed to close %d fd\n", pipefd[0]);
      return 1;
    }

    for (int i = 1; i < argc; ++i) {
      int arg_len = strlen(argv[i]);
      if (buf_end + arg_len + 1 > sizeof(buf)) {
        fprintf(stderr, "to many arguments\n");
        return 1;
      }

      strcpy(buf + buf_end, argv[i]);
      buf_end += arg_len;
      buf[buf_end++] = '\n';
    }

    char *ptr = buf;
    int len = buf_end;
    int ret = 0;
    while (len > 0) {
      ret = write(pipefd[1], ptr, len);
      if (ret < 0) {
        fprintf(stderr, "failed to write to pipe: %d\n", pipefd[1]);
        return 1;
      }
      ptr += ret;
      len -= ret;
    }

    err = close(pipefd[1]);
    if (err == -1) {
      fprintf(stderr, "failed to close %d fd\n", pipefd[1]);
      return 1;
    }

    int status;
    int child_id = wait(&status);
    (void)child_id;
    return 0;
  }
}
