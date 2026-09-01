#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  char *p;

  // Allocate one page
  p = sbrk(4096);

  // Touch the page in case lazy allocation is enabled
  p[0] = 'A';

  uint64 va1 = (uint64)p;
  uint64 va2 = va1 + 100;

  printf("VA1: 0x%lx -> PA1: 0x%lx\n", va1, va2pa(va1));

  printf("VA2: 0x%lx -> PA2: 0x%lx\n", va2, va2pa(va2));

  exit(0);
}