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

uint64 get_current_time(void) {
    /* Replace with ctime */
    return ctime();
}

/* Simple example that allocates heap memory and accesses it. */
void ul_start_func(int a1) {
    printf("[.] started the thread function (tid = %d, a1 = %d) \n", 
        get_current_tid(), a1);
    
    uint64 start_time = get_current_time();
    uint64 prev_time = start_time;

    int scheduling_rounds = 0;
    while (scheduling_rounds < 5) {
        /* If 10000 cycles have passed, yield the CPU. */
        if ((get_current_time() - prev_time) >= 10000) {
            ulthread_yield();
            /* Get time using ctime() */
            prev_time = get_current_time();
            scheduling_rounds++;
        }
    }

    /* Notify for a thread exit. */
    ulthread_destroy();
}

int
main(int argc, char *argv[])
{
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
    for (int i = 0; i < 3; i++)
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);

    /* Schedule all of the threads */
    ulthread_schedule();

    printf("[*] User-Level Threading Test #4 (RR Collaborative) Complete.\n");
    return 0;
}