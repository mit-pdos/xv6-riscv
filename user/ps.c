#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/pinfo.h"
#include "user/user.h"
#include "kernel/param.h"

int
main(int argc, char *argv[])
{
  struct pinfo info;
  int found = 0;
  
  printf("PID\tNAME\n");
  
  // Iterate through all possible PIDs
  // PIDs typically start from 1, and we check up to reasonable limit
  for(int pid = 1; pid < NPROC * 2; pid++) {
    if(getprocinfo(pid, &info) == 0) {
      // Process found
      printf("%d\t%s\n", info.pid, info.name);
      found = 1;
    }
  }
  
  if(!found) {
    printf("No processes found\n");
  }
  
  exit(0);
}
