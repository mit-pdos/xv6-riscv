// Q1: whereami
// Forks 3 CPU-bound children, then prints their stats from schedinfo().

#include "kernel/types.h"
#include "kernel/schedinfo.h"
#include "user/user.h"

int
main(void)
{
  int pids[3];
  struct schedinfo si;

  printf("parent is on hart %d\n", getcpu());

  for (int i = 0; i < 3; i++) {
    pids[i] = fork();
    if (pids[i] == 0) {
      int end = uptime() + 30;
      while (uptime() < end)
        ;
      exit(0);
    }
  }

  for (int i = 0; i < 3; i++) {
    // wait until the child is a zombie, then read its stats before wait()
    while (schedinfo(pids[i], &si) == 0 && si.state != PS_ZOMBIE)
      pause(1);
    printf("child %d: lastcpu %d, nsched %d, rticks %d\n",
           si.pid, si.lastcpu, si.nsched, si.rticks);
  }
  for (int i = 0; i < 3; i++)
    wait(0);
  exit(0);
}
