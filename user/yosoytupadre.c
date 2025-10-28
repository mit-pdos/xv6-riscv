#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int n = 2; // por defecto, el abuelo
  if(argc >= 2){
    // atoi ya viene en xv6 (user/ulib.c)
    n = atoi(argv[1]);
    if(n < 0){
      printf("uso: yosoytupadre [n>=0]\n");
      exit(1);
    }
  }

  int pid  = getpid();
  int ppid = getppid();
  int anc  = getancestor(n);

  printf("Yo soy tu padre (demo syscalls)\n");
  printf("PID actual: %d\n", pid);
  printf("PPID (con getppid): %d\n", ppid);
  printf("Ancestro %d (con getancestor): %d\n", n, anc);

  exit(0);
}
