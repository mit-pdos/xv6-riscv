#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/pinfo.h"
#include "user/user.h"

static char *
statename(int state)
{
  switch (state) {
  case 1:
    return "used";
  case 2:
    return "sleep";
  case 3:
    return "runble";
  case 4:
    return "run";
  case 5:
    return "zombie";
  default:
    return "unknown";
  }
}

int
main(int argc, char *argv[])
{
  struct pinfo info;
  int i;

  if (argc != 1) {
    fprintf(2, "usage: ps\n");
    exit(1);
  }

  if (getpinfo(&info) < 0) {
    fprintf(2, "ps: getpinfo failed\n");
    exit(1);
  }

  printf("PID\tOWNER\tPRI\tSTAT\tTICKETS\tCOMMAND\n");
  for (i = 0; i < NPROC; i++) {
    if (info.inuse[i])
      printf("%d\t%d\t%d\t%s\t%d\t%s\n",
             info.pid[i],
             info.owner[i],
             info.priority[i],
             statename(info.status[i]),
             info.tickets[i],
             info.name[i]);
  }

  exit(0);
}
