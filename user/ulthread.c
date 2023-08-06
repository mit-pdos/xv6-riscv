/* User-Level Threading Library */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"
#include "user/ulthread.h"

/* Standard definitions */
#include <stdbool.h>
#include <stddef.h> 

extern void ulthread_schedule(void);
static struct ulthread_list t_list;

/* Get thread ID */
int get_current_tid(void) {
    return t_list.current;
}

int find_available_tid(void) {
    for (int i=1; i<MAXULTHREADS; i++) {
        if(t_list.threads[i].state == FREE)
            return i;
    }
    return -1;
}

int round_robin_select(void) {
    int i = t_list.current+1;
    int ct = 0;
    while (ct < MAXULTHREADS) {
        if (i!=0 && t_list.threads[i].state == RUNNABLE)
            return i;
        i = (i+1) % MAXULTHREADS;
        ct++;
    }
    return 0;
}

int priority_select(void) {
    int hp_idx = 0;
    int hp_val = -1;
    for (int i=1; i<MAXULTHREADS; i++) {
        if (t_list.threads[i].state == RUNNABLE) {
            if (t_list.threads[i].priority > hp_val) {
                hp_idx = i;
                hp_val = t_list.threads[i].priority;
            }
        }
    }
    return hp_idx;
}

int fcfs_select(void) {
    int fc_idx = 0;
    int fc_val = ctime();
    for (int i=1; i<MAXULTHREADS; i++) {
        if (t_list.threads[i].state == RUNNABLE) {
            if (t_list.threads[i].created_at < fc_val) {
                fc_idx = i;
                fc_val = t_list.threads[i].created_at;
            }
        }
    }
    return fc_idx;
}

int select_thread(void) {
    switch(t_list.algorithm) {
        case ROUNDROBIN:
            return round_robin_select();
        case PRIORITY:
            return priority_select();
        default:
            return fcfs_select();
    }
    return 0;
}

/* Thread initialization */
void ulthread_init(int schedalgo) {
    struct ulthread *s_thread = &t_list.threads[0];
    s_thread->tid = 0;
    s_thread->state = RUNNABLE;
    s_thread->stack = malloc(PGSIZE);
    s_thread->start_func = (uint64)ulthread_schedule;
    memset(&s_thread->context, 0, sizeof(s_thread->context));
    s_thread->context.sp = s_thread->stack + PGSIZE;
    s_thread->context.ra = (uint64)ulthread_schedule;
    t_list.total = 1;
    t_list.current = 0;
    t_list.algorithm = schedalgo;
}

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {
    int tid = find_available_tid();
    if (tid == -1) {
        printf("All threads occupied :(\n");
        return false;
    }
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", tid, start, stack);
    struct ulthread *thread = &t_list.threads[tid];
    thread->tid = tid;
    thread->state = RUNNABLE;
    thread->stack = stack;
    thread->start_func = start;
    thread->priority = priority;
    thread->created_at = ctime();
    memset(&thread->context, 0, sizeof(thread->context));
    thread->context.sp = stack;
    thread->context.ra = start;
    thread->context.a0 = args[0];
    thread->context.a1 = args[1];
    thread->context.a2 = args[2];
    thread->context.a3 = args[3];
    thread->context.a4 = args[4];
    thread->context.a5 = args[5];
    t_list.total++;
    return true;
}

/* Thread scheduler */
void ulthread_schedule(void) {
    struct ulthread *s_thread = &t_list.threads[0];
    for (;;) {
        int tid = select_thread();
        if (tid == 0) {
            if (t_list.threads[t_list.yield_tid].state == YIELD) {
                tid = t_list.yield_tid;
            }
            else {
                printf("No thread to schedule. Exiting...\n");
                return;
            }
        }
        /* Make yielding thread runnable for subsequent schedules */
        if (t_list.threads[t_list.yield_tid].state == YIELD) {
            t_list.threads[t_list.yield_tid].state = RUNNABLE;
        }
        /* Add this statement to denote which thread-id is being scheduled next */
        printf("[*] ultschedule (next tid: %d)\n", tid);
        struct ulthread *r_thread = &t_list.threads[tid];
        t_list.current = tid;
        // Switch between thread contexts
        ulthread_context_switch(&s_thread->context, &r_thread->context);
    }
}

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {
    printf("[*] ultyield(tid: %d)\n", t_list.current);
    struct ulthread *c_thread = &t_list.threads[t_list.current];
    c_thread->state = YIELD;
    t_list.yield_tid = t_list.current;
    ulthread_context_switch(&c_thread->context, &t_list.threads[0].context);
}

/* Destroy thread */
void ulthread_destroy(void) {
    printf("[*] ultdestroy(tid: %d)\n", t_list.current);
    struct ulthread *c_thread = &t_list.threads[t_list.current];
    c_thread->state = FREE;
    t_list.total--;
    ulthread_context_switch(&c_thread->context, &t_list.threads[0].context);
}