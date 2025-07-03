#include "kernel/types.h" 
#include "kernel/param.h" 
#include "kernel/memlayout.h" 
#include "kernel/riscv.h" 
#include "kernel/spinlock.h" 
#include "kernel/proc.h"
#include "user/user.h" 
 
#define STACK_SIZE  100 


void release_lock() {
  lock = 0;
}

void *my_thread(void *arg) { 
    uint64 number = (uint64) arg; 
    for (int i = 0; i < 100; ++i) { 
        number++; 
        printf("thread: %lu\n", number);
 
    } 
    return (void *) number; 
} 
 
int main(int argc, char *argv[]) { 
    int sp1[STACK_SIZE], sp2[STACK_SIZE], sp3[STACK_SIZE]; 
    int ta = thread(my_thread, sp1 + STACK_SIZE, (void *) 100); 

    printf("NEW THREAD CREATED %d\n", ta);
 
    int tb = thread(my_thread, sp2 + STACK_SIZE, (void *) 200); 
    
    printf("NEW THREAD CREATED %d\n", tb); 

    int tc = thread(my_thread, sp3 + STACK_SIZE, (void *) 300); 
    
    printf("NEW THREAD CREATED %d\n", tc); 

 
    jointhread(ta); 
    jointhread(tb); 
    jointhread(tc); 
    printf("DONE\n"); 

}