#include "kernel/types.h"
#include "kernel/ps.h"
#include "user/user.h"

#define MAX_PROCS 64

static char *
state_name(int s)
{
  switch(s){
  case PS_SLEEPING:
    return "sleep";
  case PS_RUNNABLE:
    return "runnable";
  case PS_RUNNING:
    return "running";
  default:
    return "?";
  }
}

int
main(void)
{
  struct pinfo list[MAX_PROCS];
  int n = ps(list, MAX_PROCS);

  if(n < 0){
    fprintf(2, "ps: syscall failed\n");
    exit(1);
  }

  printf("PID\tSTATE\t\tSIZE(KB)\tNAME\n");
  for(int i = 0; i < n; i++){
    printf("%d\t%s\t\t%ld\t\t%s\n", list[i].pid, state_name(list[i].state), list[i].sz / 1024, list[i].name);
  }

  exit(0);
}
