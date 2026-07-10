#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/pinfo.h"
#include "user/user.h"

static int
haspid(struct pinfo *info, int pid)
{
  int i;

  for (i = 0; i < NPROC; i++) {
    if (info->inuse[i] && info->pid[i] == pid)
      return 1;
  }
  return 0;
}

int
main(int argc, char *argv[])
{
  struct pinfo info;
  int child, pspid, status;
  char *psargv[] = {"ps", 0};

  if (argc != 1) {
    fprintf(2, "usage: pstest\n");
    exit(1);
  }

  child = fork();
  if (child < 0) {
    fprintf(2, "pstest: fork failed\n");
    exit(1);
  }

  if (child == 0) {
    pause(200);
    exit(0);
  }

  pause(1);

  if (getpinfo(&info) < 0) {
    fprintf(2, "pstest: getpinfo failed\n");
    kill(child);
    wait(0);
    exit(1);
  }

  if (!haspid(&info, child)) {
    fprintf(2, "pstest: child pid %d missing from process table\n", child);
    kill(child);
    wait(0);
    exit(1);
  }

  printf("pstest: child pid %d is present; ps output follows\n", child);

  pspid = fork();
  if (pspid < 0) {
    fprintf(2, "pstest: fork ps failed\n");
    kill(child);
    wait(0);
    exit(1);
  }

  if (pspid == 0) {
    exec("ps", psargv);
    fprintf(2, "pstest: exec ps failed\n");
    exit(1);
  }

  wait(&status);
  if (status != 0) {
    kill(child);
    wait(0);
    exit(1);
  }

  kill(child);
  wait(0);

  printf("pstest: OK\n");
  exit(0);
}
