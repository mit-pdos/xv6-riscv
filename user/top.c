#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define REFRESH_TICKS 10

static char *statenames[] = {
  "unused", "used", "sleep", "runble", "run", "suspend", "zombie"
};

static char*
statename(struct pinfo *p)
{
  if(p->hibernating)
    return "hib-wip";
  if(p->hibernated)
    return "hibern";
  if(p->state >= 0 && p->state <= 6)
    return statenames[p->state];
  return "???";
}

static void
sort_by_ticks(struct pinfo *arr, int n)
{
  int i, j;
  struct pinfo tmp;
  for(i = 0; i < n - 1; i++){
    for(j = i + 1; j < n; j++){
      if(arr[j].ticks > arr[i].ticks){
        tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
      }
    }
  }
}

static uint64
find_prev_ticks(struct pinfo *prev, int nprev, int pid)
{
  for(int i = 0; i < nprev; i++){
    if(prev[i].pid == pid)
      return prev[i].ticks;
  }
  return 0;
}

int
main(int argc, char *argv[])
{
  struct pinfo *cur = malloc(NPROC * sizeof(struct pinfo));
  struct pinfo *prev = malloc(NPROC * sizeof(struct pinfo));
  int ncur, nprev = 0;
  uint t0, t1, dt;

  if(!cur || !prev){
    printf("top: malloc failed\n");
    exit(1);
  }

  t0 = uptime();

  for(;;){
    pause(REFRESH_TICKS);
    t1 = uptime();
    dt = t1 - t0;
    if(dt == 0)
      dt = 1;

    ncur = getprocs(cur, NPROC);
    if(ncur < 0){
      printf("top: getprocs failed\n");
      exit(1);
    }

    sort_by_ticks(cur, ncur);

    // ANSI clear screen + cursor home
    printf("\033[2J\033[H");

    printf("uptime: %d ticks   processes: %d   refresh: %d ticks\n",
           t1, ncur, REFRESH_TICKS);
    printf("----------------------------------------------\n");
    printf("PID\tNAME\t\tCPU%%\tMEM(KB)\tSTATE\n");
    printf("----------------------------------------------\n");

    for(int i = 0; i < ncur; i++){
      uint64 prev_ticks = find_prev_ticks(prev, nprev, cur[i].pid);
      uint64 delta = cur[i].ticks - prev_ticks;
      int cpu_pct = (int)((delta * 100) / dt);
      if(cpu_pct > 100)
        cpu_pct = 100;

      printf("%d\t%s\t\t%d%%\t%d\t%s\n",
             cur[i].pid,
             cur[i].name,
             cpu_pct,
             (int)(cur[i].sz / 1024),
             statename(&cur[i]));
    }

    // swap buffers
    for(int i = 0; i < ncur; i++)
      prev[i] = cur[i];
    nprev = ncur;
    t0 = t1;
  }
}
