#include "kernel/types.h"
#include "user/user.h"

static void print_args(int use_mutex, int mtxfd, int argc, char **argv)
{
  int i;
  char *s;

  for (i = 0; i < argc; i++) {
    for (s = argv[i]; *s; s++) {
      if (use_mutex && mutex_lock(mtxfd) < 0) {
        fprintf(2, "mutex_lock failed\n");
        return;
      }

      printf("%d: arg %d, char '%c'\n", getpid(), i, *s);

      if (use_mutex && mutex_unlock(mtxfd) < 0) {
        fprintf(2, "mutex_unlock failed\n");
        return;
      }
    }
  }
}

int main(int argc, char *argv[])
{
  int pid;
  int m;

  printf("without mutex\n");
  pid = fork();
  if (pid < 0) {
    fprintf(2, "fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    print_args(0, -1, argc, argv);
    exit(0);
  }
  print_args(0, -1, argc, argv);
  wait(0);

  printf("\nwith mutex\n");
  m = mutex();
  if (m < 0) {
    fprintf(2, "mutex() failed\n");
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    close(m);
    fprintf(2, "fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    print_args(1, m, argc, argv);
    close(m);
    exit(0);
  }

  print_args(1, m, argc, argv);
  wait(0);
  close(m);

  exit(0);
}
