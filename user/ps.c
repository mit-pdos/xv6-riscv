#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/pstat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  struct pstat uproc[NPROC];
  int nprocs;
  int i;
  uint now;
  uint age;
  char *state;

  static char *states[] = {
    [SLEEPING] = "sleeping",
    [RUNNABLE] = "runnable",
    [RUNNING] = "running",
    [ZOMBIE] = "zombie"
  };

  nprocs = getprocs(uproc);

  if(nprocs < 0){
    printf("ps: getprocs failed\n");
    exit(1);
  }

  now = uptime();

  printf("pid\tstate\t\tsize\tage\tppid\tpriority\tname\n");

  for(i = 0; i < nprocs; i++){
    state = states[uproc[i].state];
    age = 0;

    if(uproc[i].state == RUNNABLE){
      age = now - uproc[i].readytime;
    }

    printf("%d\t%s\t%ld\t",
           uproc[i].pid,
           state,
           uproc[i].size);

    if(uproc[i].state == RUNNABLE){
      printf("%d\t", age);
    } else {
      printf("-\t");
    }

    printf("%d\t%d\t\t%s\n",
           uproc[i].ppid,
           uproc[i].priority,
           uproc[i].name);
  }

  exit(0);
}
