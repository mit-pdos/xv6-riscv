#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "kernel/energy.h"
#include "user/user.h"

#define NSAMPLES 25

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

// Per-process accumulators across all samples
static unsigned long long acc_cpu[NPROC];
static unsigned long long acc_recent[NPROC];
static unsigned long long acc_runnable[NPROC];
static unsigned long long acc_sleep[NPROC];
static unsigned long long acc_energy[NPROC];
static int                acc_count[NPROC];   // how many samples included this pid
static int                acc_pid[NPROC];
static char               acc_name[NPROC][16];

static void
record_snapshot(void)
{
  static struct energyinfo info[NPROC];

  if(getenergyinfo(info) < 0){
    fprintf(2, "energytest: getenergyinfo failed\n");
    exit(1);
  }

  for(int i = 0; i < NPROC; i++){
    if(!info[i].inuse) continue;

    acc_cpu[i]      += info[i].cpu_ticks;
    acc_recent[i]   += info[i].recent_cpu_ticks;
    acc_runnable[i] += info[i].runnable_ticks;
    acc_sleep[i]    += info[i].sleep_ticks;
    acc_energy[i]   += info[i].energy_used;
    acc_pid[i]       = info[i].pid;
    acc_count[i]++;
    // copy name
    int j;
    for(j = 0; j < 15 && info[i].name[j]; j++)
      acc_name[i][j] = info[i].name[j];
    acc_name[i][j] = '\0';
  }
}

static void
print_final_snapshot(void)
{
  static struct energyinfo info[NPROC];

  if(getenergyinfo(info) < 0){
    fprintf(2, "energytest: getenergyinfo failed\n");
    exit(1);
  }

  printf("\n=== final snapshot ===\n");
  printf("PID\tSTATE\tCPU\tRECENT\tRUNNABLE\tSLEEP\tENERGY\tNAME\n");

  for(int i = 0; i < NPROC; i++){
    if(info[i].inuse){
      printf("%d\t%s\t%d\t%d\t%d\t\t%d\t%d\t%s\n",
        info[i].pid,
        statestr(info[i].state),
        info[i].cpu_ticks,
        info[i].recent_cpu_ticks,
        info[i].runnable_ticks,
        info[i].sleep_ticks,
        info[i].energy_used,
        info[i].name);
    }
  }
}

static void
print_averages(void)
{
  printf("\n=== averages over %d samples ===\n", NSAMPLES);
  printf("PID\tCPU\tRECENT\tRUNNABLE\tSLEEP\tENERGY\tNAME\n");

  for(int i = 0; i < NPROC; i++){
    if(acc_count[i] == 0) continue;
    int n = acc_count[i];
    printf("%d\t%d\t%d\t%d\t\t%d\t%d\t%s\n",
      acc_pid[i],
      (int)(acc_cpu[i]      / n),
      (int)(acc_recent[i]   / n),
      (int)(acc_runnable[i] / n),
      (int)(acc_sleep[i]    / n),
      (int)(acc_energy[i]   / n),
      acc_name[i]);
  }
}

static void
burn_loop(int rounds)
{
  volatile unsigned long long i, j;

  for(i = 0; i < (unsigned long long)rounds; i++){
    for(j = 0; j < 3000000ULL; j++){
      ;
    }
  }
}

static void short_job(void) { burn_loop(10); }
static void medium_job(void){ burn_loop(35); }
static void heavy_job(void) { burn_loop(80); }

int
main(void)
{
  int pid;

  pid = fork();
  if(pid < 0){ fprintf(2, "fork failed\n"); exit(1); }
  if(pid == 0){ short_job();  exit(0); }

  pid = fork();
  if(pid < 0){ fprintf(2, "fork failed\n"); exit(1); }
  if(pid == 0){ medium_job(); exit(0); }

  pid = fork();
  if(pid < 0){ fprintf(2, "fork failed\n"); exit(1); }
  if(pid == 0){ heavy_job();  exit(0); }

  for(int s = 0; s < NSAMPLES; s++){
    for(volatile unsigned long long d = 0; d < 150000000ULL; d++){;}
    record_snapshot();
  }

  wait(0);
  wait(0);
  wait(0);

  print_final_snapshot();
  print_averages();
  exit(0);
}