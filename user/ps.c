#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "../uproc.h"

#define MAXP 64

int
main(void)
{
  struct uproc procs[MAXP];
  int n = getprocs(procs, MAXP);

  if(n < 0){
    printf("ps: getprocs failed\n");
    exit(1);
  }

    printf("PID\tNICE\tSTATE\tVRUNTIME\tNAME\n");
    for(int i = 0; i < n; i++){
        printf("%d\t%d\t%d\t%lu\t\t%s\n",
            procs[i].pid,
            procs[i].nice,
            procs[i].state,
            procs[i].vruntime,
            procs[i].name);
    }


  exit(0);
}
