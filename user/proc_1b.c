#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = fork();
  switch (pid) {
  case -1:
    fprintf(2, "fork error");
    exit(1);
  case 0:
    pause(100);
    exit(1);
  default:
    printf("Parent process id: %d\nChild process id: %d\n", getpid(), pid);
    int err = kill(pid);
    if (err == -1) {
      fprintf(2, "process with id (%d) not found", pid);
      exit(1);
    }

    int ret_code;
    int child_id = wait(&ret_code);
    printf("finished process id (%d) returns: %d\n", child_id, ret_code);
    exit(0);
  }
}
