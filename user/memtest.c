#include "kernel/types.h"
#include "user/user.h"

void
print_meminfo(const char *label)
{
  struct meminfo mi;
  meminfo(&mi);
  printf("--- %s ---\n", label);
  printf("  Free pages  : %ld / %ld\n", mi.free_pages, mi.total_pages);
  printf("  Used pages  : %ld\n", mi.used_pages);
  printf("  Frag blocks : %ld\n", mi.frag_blocks);
}

int
main(void)
{
  printf("=== Memory Management Test ===\n\n");

  print_meminfo("Baseline");

  // Allocate 10 pages
  char *base = sbrk(0);
  sbrk(4096 * 10);
  print_meminfo("After allocating 10 pages");

  // Free alternating pages to force fragmentation
  for(int i = 0; i < 10; i += 2)
    sbrk(-4096);
  print_meminfo("After freeing alternating pages (fragmentation)");

  // Free remaining
  for(int i = 1; i < 10; i += 2)
    sbrk(-4096);
  print_meminfo("After freeing all pages");

  (void)base;
  printf("\n=== Memory Test Complete ===\n");
  exit(0);
}
