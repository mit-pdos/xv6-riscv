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
}

int
main(int argc, char *argv[])
{
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);

    printf("Testing thread creation:\n");

    /* Create more than max possible threads user-level thread */
    uint64 args[6] = {0,0,0,0,0,0};
    for (int i=0; i<MAXULTHREADS; i++) {
        ulthread_create((uint64) ul_start_func, (uint64) (stacks + PGSIZE + i*(PGSIZE)), args, -1);
    }
    
    return 0;
}