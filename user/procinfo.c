#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/pinfo.h"
#include "user/user.h"

const char *state_names[] = {
  "UNUSED",
  "USED",
  "SLEEPING",
  "RUNNABLE",
  "RUNNING",
  "ZOMBIE"
};

int
main(int argc, char *argv[])
{
  struct pinfo info;
  int pid;
  
  if(argc != 2) {
    fprintf(2, "Usage: procinfo <pid>\n");
    exit(1);
  }
  
  pid = atoi(argv[1]);
  
  if(pid <= 0) {
    fprintf(2, "procinfo: invalid pid\n");
    exit(1);
  }
  
  if(getprocinfo(pid, &info) < 0) {
    fprintf(2, "procinfo: process with pid %d not found\n", pid);
    exit(1);
  }
  
  const char *state = (info.state >= 0 && info.state <= 5) 
                       ? state_names[info.state] : "UNKNOWN";
  
  printf("Process Information:\n");
  printf("  PID:         %d\n", info.pid);
  printf("  Parent PID:  %d\n", info.parent_pid);
  printf("  State:       %s\n", state);
  printf("  Memory Size: %ld bytes\n", info.sz);
  printf("  Name:        %s\n", info.name);
  
  exit(0);
}
