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
  static struct energyinfo info[NPROC];

  if(getenergyinfo(info) < 0){
    fprintf(2, "energyps: getenergyinfo failed\n");
    exit(1);
  }

  printf("System load: %d  Temperature: %d\n\n",
    info[0].system_load, info[0].simulated_temperature);

  printf("PID\tCLASS\tSTATE\tCPU\tRECENT\tRUNNABLE\tSLEEP\tENERGY\tNAME\n");

  for(int i = 0; i < NPROC; i++){
    if(info[i].inuse){
      printf("%d\t%s\t%s\t%d\t%d\t\t%d\t%d\t%d\t%s\n",
        info[i].pid,
        info[i].green_class ? "batch" : "normal",
        statestr(info[i].state),
        info[i].cpu_ticks,
        info[i].recent_cpu_ticks,
        info[i].runnable_ticks,
        info[i].sleep_ticks,
        info[i].energy_used,
        info[i].name);
    }
  }

  exit(0);
}