#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/syscall.h"
#include "user/user.h"

// seccomp prog [args...]: run prog with open, kill, and seccomp blocked.
int
main(int argc, char **argv)
{
  int pid;
  uint64 mask;

  if (argc < 2) {
    fprintf(2, "usage: seccomp prog [args...]\n");
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    fprintf(2, "seccomp: fork failed\n");
    exit(1);
  }
  if (pid == 0) {
    mask = ~0ULL;
    mask &= ~(1ULL << SYS_open);
    mask &= ~(1ULL << SYS_kill);
    if (seccomp(mask) < 0) {
      fprintf(2, "seccomp: seccomp failed\n");
      exit(1);
    }
    exec(argv[1], argv + 1);
    fprintf(2, "seccomp: exec %s failed\n", argv[1]);
    exit(1);
  }
  wait(0);
  exit(0);
}
