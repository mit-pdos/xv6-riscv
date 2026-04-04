#include "kernel/energy.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static char *
statestr(int state)
{
  switch(state){
  case 0: return "unused";
  case 1: return "used";
  case 2: return "sleep";
  case 3: return "runble";
  case 4: return "run";
  case 5: return "zombie";
  default: return "?";
  }
}

int
main(void)
{
  struct energyinfo info[NPROC];

  if(getenergyinfo(info) < 0){
    fprintf(2, "energyps: getenergyinfo failed\n");
    exit(1);
  }

  printf("PID\tSTATE\tCPU\tRUNNABLE\tSLEEP\tENERGY\tNAME\n");

  for(int i = 0; i < NPROC; i++){
    if(info[i].inuse){
      printf("%d\t%s\t%d\t\t%d\t%d\t%d\t%s\n",
        info[i].pid,
        statestr(info[i].state),
        info[i].cpu_ticks,
        info[i].runnable_ticks,
        info[i].sleep_ticks,
        info[i].energy_used,
        info[i].name);
    }
  }

  exit(0);
}