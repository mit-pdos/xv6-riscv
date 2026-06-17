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

  // --- PART 1: baseline ---
  print_meminfo("Baseline");

  // --- PART 2: kernel fragmentation test ---
  printf("\n[Kernel-level kalloc/kfree test with 32 pages]\n\n");

  struct meminfo before;
  meminfo(&before);
  printf("Before test:\n");
  printf("  Free pages  : %ld\n", before.free_pages);
  printf("  Frag blocks : %ld\n\n", before.frag_blocks);

  // Allocate then free alternating pages — creates fragmentation
  uint64 frag_during = fragtest(32);
  printf("During alternating free (32 pages):\n");
  printf("  Frag blocks : %ld\n\n", frag_during);

  // Run coalesce — merges adjacent free blocks
  int merges = coalesce();
  printf("After coalesce():\n");
  printf("  Merges performed : %d\n", merges);
  print_meminfo("Post-coalesce");

  printf("\n[Result]\n");
  printf("  Sorted free list enables coalesce() to merge adjacent blocks\n");
  printf("  Original xv6 (unsorted) cannot guarantee adjacency detection\n");

  printf("\n=== Memory Test Complete ===\n");
  exit(0);
}
