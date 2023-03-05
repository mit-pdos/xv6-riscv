#include "types.h"
#include "riscv.h"

#include "defs.h"

#include "processlocks.h"

#define SYS_PROCESS_LOCK_ALLOCATE 0
#define SYS_PROCESS_LOCK_FREE     1
#define SYS_PROCESS_LOCK_ACQUIRE  2
#define SYS_PROCESS_LOCK_RELEASE  3

uint64 sys_process_lock() {
  int type;
  argint(0, &type);
  if (type == SYS_PROCESS_LOCK_ALLOCATE)
    return processlocks_allocate();
  int processlock_id;
  argint(1, &processlock_id);
  if (type == SYS_PROCESS_LOCK_FREE)
    return processlocks_free(processlock_id);
  if (type == SYS_PROCESS_LOCK_ACQUIRE)
    return processlocks_acquire(processlock_id);
  if (type == SYS_PROCESS_LOCK_RELEASE)
    return processlocks_release(processlock_id);
  return -1;
}
