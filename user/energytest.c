#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = getpid();
  int e = getenergy(pid);
  printf("pid=%d energy=%d\n", pid, e);
  exit(0);
}
//The function below was used for debugging. It runs a busy loop for a while and then prints the energy consumed by the process. You can run it with "energytest" command in the xv6 shell.
//Modify 500000000 to test different amounts of energy consumption. 
/*
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = getpid();
  volatile int i;

  printf("starting pid=%d\n", pid);

  for(i = 0; i < 900000000; i++){
    ;
  }

  printf("ending pid=%d energy=%d\n", pid, getenergy(pid));
  exit(0);
}
  */