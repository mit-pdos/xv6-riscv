#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

#include <stdarg.h>

int
main(int argc, char *argv[])
{
    /* Allocate as many pages as allowed. */
    int npages = 101;
    void* heappages = sbrk(4096*npages);
    if (!heappages) {
        printf("[X] Heap memory allocation FAILED.\n");
        return -1;
    }

    int* a;
    a = ((int*) (heappages + 99*PGSIZE));
    *a = 99;
    printf("Wrote data to page 100 and sleeping for 5 seconds...\n");
    sleep(50);

    a = ((int*) (heappages + 98*PGSIZE));
    *a = 98;
    printf("Wrote data to page 99 and sleeping for 5 seconds...\n");
    sleep(50);

    int count = 0;
    for (int i = 0; i < (npages-1); i++) {
        a = ((int*) (heappages + i*PGSIZE));
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            *a = count;
            a++;
        }
        count++;
    }
    printf("Wrote data to pages 1 to 98\n");
    printf("Attempting to write to page 101\n");
    a = ((int*) (heappages + 100*PGSIZE));
    *a = count;
    printf("\nIf prev. line reads 'EVICT: Page (66000) --> PSA (0 - 3)', TEST PASSED.\n");
    printf("Although page 100 was first written to, \n");
    printf("since page 99 is also not part of the working set (WS_THRESHOLD = 3 seconds), \n");
    printf("Page 99 (VA 66000) (numerically) should be the evicted page. \n");
    printf("\nNOTE: If test fails, make sure that in kernel/pfault.c:261, \n");
    printf("true is passed to evict_page_to_disk() so that it uses the working set algorithm.");
    printf("\nIf test fails even otherwise, please consider partial points (◔ᴥ◔)\n");

    return 0;
}