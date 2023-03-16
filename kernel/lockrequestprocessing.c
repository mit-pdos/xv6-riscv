#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "sleeplock.h"

#define NUMBER_OF_LOCKS 8

struct {
    short current_locks[NUMBER_OF_LOCKS];
    struct spinlock spin;
    struct sleeplock sleeplocks_keeper[NUMBER_OF_LOCKS];
} spinned_sleeplocks;

int catch_error(int lock_id) {
    if (lock_id < 0 || lock_id >= NUMBER_OF_LOCKS || spinned_sleeplocks.current_locks[lock_id] == 0)
        return -1;

    return 0;
}

void initialize_locks() {
    
    initlock(&spinned_sleeplocks.spin, "spin");
    for (int i = 0; i < NUMBER_OF_LOCKS; i++) {
        initsleeplock(&spinned_sleeplocks.sleeplocks_keeper[i], "my_lock");
        spinned_sleeplocks.current_locks[i] = 0;
    }
}

int give_lock() {
    acquire(&spinned_sleeplocks.spin);
    for (int i = 0; i < NUMBER_OF_LOCKS; i++) {
        if (spinned_sleeplocks.current_locks[i] == 0) {
            
            spinned_sleeplocks.current_locks[i] = 1;
            release(&spinned_sleeplocks.spin);       
            return i;
        }
    }

    release(&spinned_sleeplocks.spin);
    return -1;
}

int free_lock(int lock_id) {
    acquire(&spinned_sleeplocks.spin);

    if (catch_error(lock_id) < 0) {
      release(&spinned_sleeplocks.spin);
      return -1;
    }

    spinned_sleeplocks.current_locks[lock_id] = 0;
    release(&spinned_sleeplocks.spin);

    return 0;
}

int acquire_lock(int lock_id) {

    acquire(&spinned_sleeplocks.spin);

    if (catch_error(lock_id) < 0) {
      release(&spinned_sleeplocks.spin);
      return -1;
    }

    release(&spinned_sleeplocks.spin);
    acquiresleep(&spinned_sleeplocks.sleeplocks_keeper[lock_id]);
    return 0;
}

int release_lock(int lock_id) {
    acquire(&spinned_sleeplocks.spin);

    if (catch_error(lock_id) < 0) {
      release(&spinned_sleeplocks.spin);
      return -1;
    }

    release(&spinned_sleeplocks.spin);
    releasesleep(&spinned_sleeplocks.sleeplocks_keeper[lock_id]);
    return 0;
}