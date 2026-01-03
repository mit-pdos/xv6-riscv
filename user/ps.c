#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/pstat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  struct pstat ps;
  
  if(getpinfo(&ps) < 0) {
    fprintf(2, "ps: getpinfo failed\n");
    exit(1);
  }
  
  // Print header
  printf("PID\tPPID\tPRIOR\tSTATE\t\tNAME\t\tSIZE\tTICKS\tWAIT\n");
  printf("---\t----\t-----\t-----\t\t----\t\t----\t-----\t----\n");
  
  // Print process information
  for(int i = 0; i < NPROC; i++) {
    if(ps.inuse[i]) {
      printf("%d\t%d\t%d\t%s\t\t%s\t\t%d\t%d\t%d\n",
             ps.pid[i],
             ps.ppid[i],
             ps.priority[i],
             ps.state[i],
             ps.name[i],
             ps.sz[i],
             ps.ticks[i],
             ps.wait_ticks[i]);
    }
  }
  
  exit(0);
}