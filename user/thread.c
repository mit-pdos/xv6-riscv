#include "test.c"
#include "thread.h"

void thread_init(void){
    current_thread = &all_thread[0];
    current_thread->state = RUNNING;
    // current_thread->priority = -1e9;
    // current_thread->counter = 0;
    current_thread->thread_id = 0;
    // current_thread->stamp = 0;
}

static void thread_create(int thread_id, void *func){
    thread_p t;
    int free = 0;

    for (t = all_thread; t < all_thread + MAX_THREAD; t++){
        if(t->state == FREE){
            free = 1;
            break;
        }
    }

    if(free== 0){
        printf("Thread creation unsuccessful. MAX_THREAD limit reached \n");
        return 0;    // no space for threads available, max_threads limit reached
    }
    else{
        t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
        t->sp -= 4;                              // space for return address
        * (int *) (t->sp) = (int)func;           // push return address on stack
        t->sp -= 32;                             // space for registers that thread_switch will push
        t->state = RUNNABLE;
        t->thread_id = thread_id;
        printf(2,"Thread \'%d\' successfully created with p = %d\n",t->thread_id);
        return 1;
  }
}

int main(int argc, char const *argv[]){
    thread_init();
    thread_create(1, test1);
    return 0;
}