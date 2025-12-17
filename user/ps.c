#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
#include "pstat.h"

int main(void) {
  struct pstat ps;

  if(getpinfo(&ps) < 0){
    printf("getpinfo failed\n");
    exit(1);
  }

  printf("PID\tPPID\tPRIO\tSTATE\tSIZE\tNAME\n");
  for(int i = 0; i < MAXPROC; i++){
    if(ps.pid[i] > 0){
      printf("%d\t%d\t%d\t%d\t%d\t%s\n",
             ps.pid[i],
             ps.ppid[i],
             ps.priority[i],
             ps.state[i],
             ps.size[i],
             ps.name[i]);
    }
  }
  exit(0);
}
