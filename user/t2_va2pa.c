#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int n = 10;
  uint64 va = (uint64)&n;

  int pid = fork();

  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  } else if (pid == 0) {
    // Child
    printf("Virtual address  of variable N in child :  0x%lx\n", va);
    printf("Physical address of variable N in child :  0x%lx\n", va2pa(va));

    exit(0);
  } else {
    // Parent
    wait(0);

    printf("Virtual address  of variable N in parent : 0x%lx\n", va);
    printf("Physical address of variable N in parent : 0x%lx\n", va2pa(va));

    exit(0);
  }
}