#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int pid = fork();

  if(pid == 0){
    // child: run burn
    volatile unsigned long long i;
    for(i = 0; i < 5000000000ULL; i++){
    }
    exit(0);
  } else {
    // parent: give child time to run
    for(int i = 0; i < 100000000; i++) { }

    // now run energyps
    char *args[] = { "energyps", 0 };
    exec("energyps", args);

    // fallback if exec fails
    wait(0);
  }

  exit(0);
}