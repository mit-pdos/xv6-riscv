#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "kernel/energy.h"
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

static void
burn_cpu(int rounds)
{
  volatile unsigned long long i, j;
  for(i = 0; i < (unsigned long long)rounds; i++)
    for(j = 0; j < 3000000ULL; j++)
      ;
}

static void
print_snapshot(int sample)
{
  static struct energyinfo info[NPROC];
  if(getenergyinfo(info) < 0) return;

  printf("\n--- sample %d  load=%d  temp=%d ---\n",
    sample, info[0].system_load, info[0].simulated_temperature);
  printf("PID\tCLASS\tSTATE\tCPU\tENERGY\tNAME\n");
  for(int i = 0; i < NPROC; i++){
    if(info[i].inuse && info[i].pid > 2){
      printf("%d\t%s\t%s\t%d\t%d\t%s\n",
        info[i].pid,
        info[i].green_class ? "BATCH" : "normal",
        statestr(info[i].state),
        info[i].cpu_ticks,
        info[i].energy_used,
        info[i].name);
    }
  }
}

int
main(void)
{
  int ipid, b1pid, b2pid;

  printf("=== Green Batch Scheduler Demo ===\n\n");
  printf("Policy: BATCH jobs skipped when load >= 2 or temp >= 30\n");
  printf("Running on 1 CPU so all processes compete for the scheduler.\n\n");

  printf("Spawning processes:\n");
  printf("  [normal] interactive -- small CPU bursts + sleeps\n");
  printf("  [BATCH]  batch-1     -- heavy CPU burn\n");
  printf("  [BATCH]  batch-2     -- heavy CPU burn\n\n");

  ipid = fork();
  if(ipid < 0){ printf("fork failed\n"); exit(1); }
  if(ipid == 0){
    for(int i = 0; i < 40; i++){
      burn_cpu(2);
      pause(8);
    }
    exit(0);
  }

  b1pid = fork();
  if(b1pid < 0){ printf("fork failed\n"); exit(1); }
  if(b1pid == 0){
    setgreenclass(1);
    burn_cpu(150);
    exit(0);
  }

  b2pid = fork();
  if(b2pid < 0){ printf("fork failed\n"); exit(1); }
  if(b2pid == 0){
    setgreenclass(1);
    burn_cpu(150);
    exit(0);
  }

  printf("Spawned: interactive=pid%d  batch-1=pid%d  batch-2=pid%d\n\n",
    ipid, b1pid, b2pid);
  printf("Watch: BATCH stays 'runble' (deferred) while interactive runs.\n");
  printf("BATCH only runs when load drops (interactive sleeps).\n");

  for(int s = 0; s < 14; s++){
    pause(20);
    print_snapshot(s);
  }

  wait(0);
  wait(0);
  wait(0);

  static struct energyinfo final[NPROC];
  if(getenergyinfo(final) == 0){
    printf("\n=== Final Energy Report ===\n");
    printf("PID\tCLASS\tCPU\tEnergy\tName\n");
    for(int i = 0; i < NPROC; i++){
      if(final[i].inuse && final[i].pid > 2){
        printf("%d\t%s\t%d\t%d\t%s\n",
          final[i].pid,
          final[i].green_class ? "BATCH" : "normal",
          final[i].cpu_ticks,
          final[i].energy_used,
          final[i].name);
      }
    }
    printf("\nBATCH jobs use less energy because they only ran when idle.\n");
  }

  printf("\n=== Demo Complete ===\n");
  exit(0);
}
