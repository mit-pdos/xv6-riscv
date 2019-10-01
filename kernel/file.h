#pragma once

#include "fs.h"
#include "pipe.h"
#include "types.h"

struct file {
  enum { FD_NONE, FD_PIPE, FD_INODE, FD_DEVICE } type;
  int ref; // reference count
  char readable;
  char writable;
  struct pipe *pipe; // FD_PIPE
  struct inode *ip;  // FD_INODE and FD_DEVICE
  uint off;          // FD_INODE
  short major;       // FD_DEVICE
};

#define major(dev)  ((dev) >> 16 & 0xFFFF)
#define minor(dev)  ((dev) & 0xFFFF)
#define mkdev(m,n)  ((uint)((m)<<16| (n)))

// map major device number to device functions.
struct devsw {
  int (*read)(int, uint64, int);
  int (*write)(int, uint64, int);
};

extern struct devsw devsw[];

#define CONSOLE 1


struct file* filealloc(void);
void         fileclose(struct file*);
struct file* filedup(struct file*);
void         fileinit(void);
int          fileread(struct file*, uint64, int n);
int          filestat(struct file*, uint64 addr);
int          filewrite(struct file*, uint64, int n);
