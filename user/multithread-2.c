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
    printf("[.] started the thread function (tid = %d) \n", get_current_tid());

    /* Notify for a thread exit. */
    ulthread_destroy();
}

int
main(int argc, char *argv[])
{
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));

    /* Initialize the user-level threading library */
    ulthread_init(PRIORITY);

    /* Create a user-level thread */
    uint64 args[6] = {0,0,0,0,0,0};
    for (int i = 0; i < 10; i++)
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, i%10);

    /* Schedule all of the threads */
    ulthread_schedule();

    printf("[*] User-Level Threading Test #2 (Priority Scheduling) Complete.\n");
    return 0;
}
