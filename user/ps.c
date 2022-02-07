#include "user.h"
#include "kernel/pstat.h"
#include "kernel/param.h"

int main(int argc, char **argv) {
  int show_all = 0;
  if (argc >=2 && (strcmp(argv[1], "--all") == 0)) {
    // show inactive processes as well
    show_all = 1; 
  }


  struct pstat p;
  if (getpinfo(&p) != 0) {
    printf("Error: getpinfo failed\n"); // stderr
    exit(1);
  }
  printf("PID,INUSE,TICKETS\n");
  for (int i = 0; i < NPROC; ++i) {
    if (show_all || p.inuse[i]) {
      printf("%d,%d,%d\n", p.pid[i], p.inuse[i], p.tickets[i]);
    }
  }
  exit(0);
}

