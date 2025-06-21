#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
extern struct proc proc[NPROC];
extern struct cpu cpus[NCPU];

void
sys_pstate(void)
{
    //Prints out the pricess id, process name, process state, nad parent name.
    struct proc *p;
    int runCounter = 0;
    int sleepCounter = 0;
    int runnableCounter = 0;
    for(p = proc; p < &proc[NPROC]; p++) {
        if(p->state == RUNNABLE) {
            runnableCounter++;
        } else if(p->state == RUNNING) {
            runCounter++;
        } else if(p->state == SLEEPING) {
            sleepCounter++;
        }        
        if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING)
        {
            printf("pid: %d, state: %d, name: %s, parent: %s\n", p->pid, p->state, p->name, p->parent ? p->parent->name : "(init)");
        }
    }
    printf("Process State Summary:\n");
    printf("RUNNABLE: %d\n", runnableCounter);
    printf("RUNNING: %d\n", runCounter);
    printf("SLEEPING: %d\n", sleepCounter);
    
}
