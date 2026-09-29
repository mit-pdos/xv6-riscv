#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/syscall.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  int pid;

  if (argc < 3) {
    fprintf(2, "usage: chroot dir prog [args...]\n");
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    fprintf(2, "chroot: fork failed\n");
    exit(1);
  }
  if (pid == 0) {
    if (chroot(argv[1]) < 0) {
      fprintf(2, "chroot: chroot failed\n");
      exit(1);
    }
    if (chdir("/") < 0) {
      fprintf(2, "chroot: chdir failed\n");
      exit(1);
    }
    exec(argv[2], argv + 2);
    fprintf(2, "chroot: exec %s failed\n", argv[2]);
    exit(1);
  }
  wait(0);
  exit(0);
}
