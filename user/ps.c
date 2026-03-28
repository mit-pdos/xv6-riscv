#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/procinfo.h"
#include "user/user.h"

static char*
statestr(int st)
{
  switch (st) {
  case PI_UNUSED:   return "unused";
  case PI_USED:     return "used";
  case PI_SLEEPING: return "sleep";
  case PI_RUNNABLE: return "runble";
  case PI_RUNNING:  return "run";
  case PI_ZOMBIE:   return "zombie";
  default:          return "?";
  }
}

int
main(void)
{
  int n, m;
  struct procinfo* plist;

  n = ps_listinfo(0, 0);
  if (n < 0) {
    fprintf(2, "ps: ps_listinfo(NULL) failed\n");
    exit(1);
  }

  m = n + 8;
  plist = 0;

  while (1) {
    plist = malloc(m * sizeof(struct procinfo));
    if (plist == 0) {
      fprintf(2, "ps: malloc failed\n");
      exit(1);
    }

    n = ps_listinfo(plist, m);
    if (n < 0) {
      fprintf(2, "ps: ps_listinfo failed: %d\n", n);
      free(plist);
      exit(1);
    }
    if (n > m) {
      free(plist);
      m = n + 8;
      continue;
    }
    break;
  }

  printf("PID NAME   STATE PPID PNAME\n");

  for (int i = 0; i < n; i++) {
    printf("%d   %s   %s   %d    %s\n",
      plist[i].pid,
      plist[i].name,
      statestr(plist[i].state),
      plist[i].ppid,
      plist[i].pname);
  }

  free(plist);
  exit(0);
}