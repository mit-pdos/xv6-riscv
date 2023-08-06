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
    int start_time = ctime();
    int scheduled_rounds = 0;
    for(;;) {
        if((ctime() - start_time) > 10000) {
            if((ctime() - start_time) > 100000) {
                scheduled_rounds++;
                ulthread_yield();
            }
        }
        if (scheduled_rounds == 5) {
            ulthread_destroy();
        }
    }
}

int
main(int argc, char *argv[])
{
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);

    printf("Testing yield:\n");

    /* Create user-level threads */
    uint64 args[6] = {0,0,0,0,0,0};  
    for (int i=0; i<5; i++) {
        ulthread_create((uint64) ul_start_func, (uint64) (stacks + PGSIZE + i*(PGSIZE)), args, -1);
    }

    /* Schedule threads */
    ulthread_schedule();

    printf("[*] Thread Yield Test Complete.\n");
    return 0;
}