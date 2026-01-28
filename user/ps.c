#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/getproc.h"

int
main(int argc, char *argv[])
{
  struct procinfo procs[64];
  int n, i;
  char *states[] = {"unused", "used", "sleep", "runble", "run", "zombie"};

  n = getprocs(procs, 64);
  if(n < 0){
    fprintf(2, "ps: getprocs failed\n");
    exit(1);
  }

  printf("PID\tSTATE\t\tSIZE\tNAME\n");
  for(i = 0; i < n; i++){
    printf("%d\t%s\t\t%d\t%s\n",
           procs[i].pid,
           states[procs[i].state],
           (int)procs[i].sz,
           procs[i].name);
  }

  exit(0);
}
