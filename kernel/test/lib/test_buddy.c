#include "types.h"
#include "param.h"
#include "arch/riscv.h"
#include "defs.h"
#include "lib/buddy.h"

extern uint64 bd_allocated;

void buddy_test() {
  if (cpuid() == 0) {

    // ticksleep(10);
    printf("\t[buddy test] start...");
    // page alloc
    for (int n = 0; n < 1000; n++) {
      void *pages_4096[MAX_PAGES];
      // void *pages_2048[MAX_PAGES << 1];
      // void *pages_1024[MAX_PAGES << 2];
      // void *pages_512[MAX_PAGES << 3];
      // void *pages_256[MAX_PAGES << 4];
      // void *pages_128[MAX_PAGES << 5];
      // void *pages_64[MAX_PAGES << 6];
      for (int i = 0; i < MAX_PAGES; i++) {
        pages_4096[i] = bd_alloc(PGSIZE);
        memset(pages_4096[i], 0xa, PGSIZE);
      }
      for (int i = 0; i < MAX_PAGES; i++) {
        bd_free(pages_4096[i]);
      }
    }
    printf("finish! \n");
  }
}