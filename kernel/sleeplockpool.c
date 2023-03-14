#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

#define SLEEPLOCK_POOL_SIZE 512

struct sleeplock pool[SLEEPLOCK_POOL_SIZE];
int is_free[SLEEPLOCK_POOL_SIZE];
int free_locks[SLEEPLOCK_POOL_SIZE];
int head;
struct spinlock pool_lock;

void initsleeplockpool() {
    head = 0;

    initlock(&pool_lock, "sleeplock pool lock");

    for (int i = 0; i < SLEEPLOCK_POOL_SIZE; i++) {
        pool[i].lk = pool_lock;
        pool[i].pid = 0;
        free_locks[i] = i;
        is_free[i] = 1;
    }
}

int initpoollock(int* ld) {
    acquire(&pool_lock);
    if (head == SLEEPLOCK_POOL_SIZE)
        return -2; // no locks available

    *ld = free_locks[head++];
    is_free[*ld] = 0;
    release(&pool_lock);
    return 0;
}

static int check_ld_is_valid(int ld) {
    acquire(&pool_lock);
    if (ld < 0 || SLEEPLOCK_POOL_SIZE <= ld) {
        release(&pool_lock);
        return -1; // index is out of bounds
    }
    if (is_free[ld]) {
        release(&pool_lock);
        return -3; // uninitialized lock
    }
    release(&pool_lock);
    return 0;
}

int acquirepoollock(int ld) {
    int error = check_ld_is_valid(ld); 
    if (error)
        return error;
    
    acquiresleep(&pool[ld]);
    return 0;
}

int releasepoollock(int ld) {
    int error = check_ld_is_valid(ld); 
    if (error)
        return error;
    
    releasesleep(&pool[ld]);
    return 0;
}

int holdingpoollock(int ld) {
    int error = check_ld_is_valid(ld); 
    if (error)
        return error;
    
    return holdingsleep(&pool[ld]);
}

int deletepoollock(int ld) {
    int error = check_ld_is_valid(ld); 
    if (error)
        return error;
    
    releasesleep(&pool[ld]);

    acquire(&pool_lock);
    is_free[ld] = 1;
    head--;
    free_locks[head] = ld;
    release(&pool_lock);

    return 0;
}