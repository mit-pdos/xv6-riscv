#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Each page is 4096 bytes. We allocate well beyond physical RAM
// (xv6 default is 128MB but QEMU is often configured to 8-16MB for testing).
// 2000 pages = ~8MB -- enough to force eviction on a tight QEMU config.
#define NPAGES   2000
#define PAGESIZE 4096

// We write a unique stamp to the first word of every page,
// then walk back and verify. If any stamp is wrong, a page came
// back from swap with corrupted data.
int
main(void)
{
  printf("swaptest: allocating %d pages (%d KB)...\n",
         NPAGES, (NPAGES * PAGESIZE) / 1024);

  char *base = sbrk(NPAGES * PAGESIZE);
  if (base == (char*)-1) {
    printf("swaptest: sbrk failed\n");
    exit(1);
  }

  // Write phase -- touch every page with a unique value.
  printf("swaptest: write phase\n");
  for (int i = 0; i < NPAGES; i++) {
    // Cast to int* so we write 4 bytes at once.
    int *p = (int *)(base + (uint64)i * PAGESIZE);
    *p = i + 1;   // stamp = page index + 1 (never zero)
  }

  // Read-back phase -- verify every stamp.
  printf("swaptest: verify phase\n");
  int failures = 0;
  for (int i = 0; i < NPAGES; i++) {
    int *p = (int *)(base + (uint64)i * PAGESIZE);
    if (*p != i + 1) {
      printf("swaptest: FAIL page %d: expected %d got %d\n",
             i, i + 1, *p);
      failures++;
      if (failures > 5) {
        printf("swaptest: too many failures, aborting\n");
        exit(1);
      }
    }
  }

  if (failures == 0)
    printf("swaptest: PASS -- all %d pages verified\n", NPAGES);
  else
    printf("swaptest: FAIL -- %d corrupted pages\n", failures);

  exit(0);
}