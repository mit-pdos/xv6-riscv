// Q2: slicetest
// Two CPU hogs run for 100 ticks, one with slice 1 and one with slice 10.
// rticks / nsched is how long each process kept the CPU per turn,
// so it should be close to its slice.

#include "kernel/types.h"
#include "kernel/schedinfo.h"
#include "user/user.h"

int
main(void)
{
  int slices[2] = { 1, 10 };
  int pids[2];
  struct schedinfo si;
  int end = uptime() + 100;

  for (int i = 0; i < 2; i++) {
    pids[i] = fork();
    if (pids[i] == 0) {
      setslice(0, slices[i]);
      while (uptime() < end)
        ;
      exit(0);
    }
  }

  for (int i = 0; i < 2; i++) {
    while (schedinfo(pids[i], &si) == 0 && si.state != PS_ZOMBIE)
      pause(1);
    printf("slice %d: rticks %d, nsched %d, ticks per turn %d (expected about %d)\n",
           si.slice, si.rticks, si.nsched, si.rticks / si.nsched, si.slice);
  }
  for (int i = 0; i < 2; i++)
    wait(0);
  exit(0);
}
