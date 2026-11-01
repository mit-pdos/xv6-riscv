// Q3: forkrace
// Forks 3 children with forkwatch on. After each fork the parent keeps
// the CPU busy for 5 ticks, then it prints the children's first-run stats.
// With a free hart the child runs at once (ftime == ctime); with
// make CPUS=1 qemu it must wait for the parent's slice to end (ftime > ctime).

#include "kernel/types.h"
#include "kernel/schedinfo.h"
#include "user/user.h"

int
main(void)
{
  int pids[3];
  struct schedinfo si[3];

  forkwatch(1);
  for (int i = 0; i < 3; i++) {
    pids[i] = fork();
    if (pids[i] == 0)
      exit(0);
    int end = uptime() + 5;
    while (uptime() < end)
      ;
  }

  for (int i = 0; i < 3; i++)
    while (schedinfo(pids[i], &si[i]) == 0 && si[i].state != PS_ZOMBIE)
      pause(1);
  forkwatch(0);

  for (int i = 0; i < 3; i++)
    printf("child %d: ctime %d, ftime %d, waited %d ticks, firstcpu %d\n",
           si[i].pid, si[i].ctime, si[i].ftime, si[i].ftime - si[i].ctime, si[i].firstcpu);
  for (int i = 0; i < 3; i++)
    wait(0);
  exit(0);
}
