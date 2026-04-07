// clang-format off
#include "types.h"
#include "riscv.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "stat.h"
#include "fs.h"
#include "file.h"
#include "defs.h"
#include "ptfs.h"

// clang-format on
extern struct {
  struct spinlock lock;
  struct inode inode[NINODE];
} itable;

struct tag_priority tag_table[MAX_TAG_TABLE];
static int tag_table_count;

static struct spinlock ptfs_lock;
static int ptfs_lock_ready;

static void ptfs_init_lock(void) {
  if (ptfs_lock_ready)
    return;
  initlock(&ptfs_lock, "ptfs");
  ptfs_lock_ready = 1;
}

int get_tag_priority(char *tag) {
  int i;

  if (tag == 0)
    return 0;

  ptfs_init_lock();
  acquire(&ptfs_lock);
  for (i = 0; i < tag_table_count; i++) {
    if (strncmp(tag_table[i].tag, tag, TAG_LENGTH) == 0) {
      int pr = tag_table[i].priority;
      release(&ptfs_lock);
      return pr;
    }
  }
  release(&ptfs_lock);
  return 0;
}
