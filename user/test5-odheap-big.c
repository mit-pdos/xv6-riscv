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

/* Simple example that allocates heap memory and accesses it. */

int
main(int argc, char *argv[])
{
    /* Allocate as many pages as allowed. */
    int npages = MAXHEAP;
    void* heappages = sbrk(4096*npages);
    if (!heappages) {
        printf("[X] Heap memory allocation FAILED.\n");
        return -1;
    }

    /* Write random numbers to the allocated heap regions. */
    int* a;
    int count = 0;
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            *a = count;
            a++;
        }
        count++;
    }

    /* Assert heap memory correctness by checking the regions. */
    count = 0;
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            if (*a != count) 
                goto fail;
            a++;
        }
        count++;
    }

    printf("[*] Heap test PASSED.\n");
    return 0;

fail:
    printf("[X] Heap test FAILED.\n");
    return -1;
}