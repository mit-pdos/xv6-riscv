#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

#include "user/ulthread.h"
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(void) {
    /* Start the thread here. */
    for (int i=1; i<MAXULTHREADS; i++) {
        int tid = get_current_tid();
        printf("[.] entered the thread function (tid = %d) \n", tid);
        if (tid == i)
            ulthread_destroy();
        else
            ulthread_yield();
    }
}

int
main(int argc, char *argv[])
{
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);

    printf("Testing multithreading:\n");
    printf("Thread 1 should execute once and get destroyed\n");
    printf("Thread 2 should be scheduled twice before getting destroyed\n");
    printf("Thread 8 should be scheduled eight times before yielding at the end\n");

    /* Create user-level threads */
    uint64 args[6] = {0,0,0,0,0,0};  
    for (int i=0; i<8; i++) {
        ulthread_create((uint64) ul_start_func, (uint64) (stacks + PGSIZE + i*(PGSIZE)), args, -1);
    }

    /* Schedule some of the threads */
    ulthread_schedule();

    printf("[*] User-Level Round-Robin Multithreading Test Complete.\n");
    return 0;
}