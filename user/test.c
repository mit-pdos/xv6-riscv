#include "thread.h"

static void test1(void){
    printf(1, "thread %d created\n",current_thread->thread_id);
    printf(1, "thread %s exit \n" , current_thread->thread_id);
    current_thread->state = FREE;
    // thread_schedule();
}