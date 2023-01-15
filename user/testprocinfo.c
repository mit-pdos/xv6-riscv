#include "kernel/types.h"
#include "user/user.h"
#include "kernel/pstat.h"

int
main(int argc, char *argv[])
{
  if (argc != 1) {
    fprintf(2, "Usage: %s\n", argv[0]);
    exit(1);
  }

  struct pstat ps;
  if (getpinfo(&ps) < 0) {
    fprintf(2, "getpinfo sys_call failed\n");
    exit(1);
  }
  
  printf("PID | In Use | Original Tickets | Current Tickets | Time Slices\n");
  for (int i = 0; i < NPROC; ++i) {
    if (ps.inuse[i]) {
      printf("%d | %d | %d | %d | %d\n", ps.pid[i], ps.inuse[i], ps.tickets_original[i], ps.tickets_current[i], ps.time_slices[i]);  
    }
  }

  exit(0);
}
