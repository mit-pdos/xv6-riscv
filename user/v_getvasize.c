#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = getpid();

  printf("Pid of the process is %d\n", pid);

  uint64 process_size_before_sbrk = getvasize(getpid());

  printf("Size of process:          %lu Bytes\n", process_size_before_sbrk);

  printf("Address returned by sbrk: %p\n", sbrk(0));

  char *sbrk_after = sbrk(1024);

  uint64 process_size_after_sbrk = getvasize(getpid());

  printf("Size of process:          %lu Bytes\n", process_size_after_sbrk);

  printf("Address returned by sbrk: %p\n", sbrk_after);

  exit(0);
}