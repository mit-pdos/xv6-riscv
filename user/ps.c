#include "kernel/types.h"
#include "user/user.h"
#include "kernel/procinfo.h"


char *
state_name(enum procstate state)
{
  switch (state) {
    case SLEEPING: return "SLEEPING";
    case RUNNABLE: return "RUNNABLE";
    case RUNNING:  return "RUNNING";
    case ZOMBIE:   return "ZOMBIE";
    default:       return "UNKNOWN";
  }
}


int
main()
{
  int lim = 4;
  int total_proc;
  struct procinfo *plist;
  
  while (1)
  {
    plist = malloc(lim * sizeof(struct procinfo));
    if (plist == 0) exit(-1);

    total_proc = ps_listinfo(plist, lim);
    if (total_proc < 0)
    {
      free(plist);
      exit(-1);
    }

    if (total_proc <= lim) break;

    free(plist);
    lim = total_proc;
  }

  printf("PID NAME STATE PPID\n");

  for (int i = 0; i < total_proc; i++) {
    printf("%d %s %s %d\n",
      plist[i].pid,
      plist[i].name,
      state_name(plist[i].state),
      plist[i].ppid
    );
  }
  free(plist);
  exit(0);
}
