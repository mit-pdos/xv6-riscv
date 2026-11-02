//
// Support functions for system calls that involve file descriptors.
//

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "stat.h"
#include "proc.h"
#include "sysinfo.h"

extern struct proc proc[NPROC];

struct devsw devsw[NDEV];
struct {
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file *
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    if (f->ref == 0) {
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if (f->ref < 1)
    panic("filedup");
  f->ref++;
  release(&ftable.lock);
  return f;
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
  struct file ff;

  acquire(&ftable.lock);
  if (f->ref < 1)
    panic("fileclose");
  if (--f->ref > 0) {
    release(&ftable.lock);
    return;
  }
  ff = *f;
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if (ff.type == FD_PIPE) {
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    begin_op();
    iput(ff.ip);
    end_op();
  }
}

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
  struct proc *p = myproc();
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    ilock(f->ip);
    stati(f->ip, &st);
    iunlock(f->ip);
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
      return -1;
    return 0;
  }
  return -1;
}

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
  int r = 0;

  if (f->readable == 0 || n < 0)
    return -1;

  if (f->type == FD_PIPE) {
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    ilock(f->ip);
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
  } else {
    panic("fileread");
  }

  return r;
}

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    return -1;

  if (f->type == FD_PIPE) {
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    // write a few blocks at a time to avoid exceeding
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
      int n1 = n - i;
      if (n1 > max)
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
        f->off += r;
      iunlock(f->ip);
      end_op();

      if (r != n1) {
        // error from writei
        break;
      }
      i += r;
    }
    ret = (i == n ? n : -1);
  } else {
    panic("filewrite");
  }

  return ret;
}

// TODO(A): thay stub này bằng bản đầy đủ
int
fill_fileinfo(uint64 addr)
{
  struct proc *p = myproc();
  struct fileinfo fi; // ~88 bytes, ok cho kernel stack
  int n = 0;

  for (int i = 0; i < NFILE && n < MAXFILEINFO; i++) {
    struct file *f = &ftable.file[i];

    // 1) Chụp thông tin file dưới ftable.lock, rồi thả lock
    acquire(&ftable.lock);
    if (f->ref == 0) {
      release(&ftable.lock);
      continue;
    }
    memset(&fi, 0, sizeof(fi));
    fi.id = i;
    fi.type = (int)f->type;
    fi.readable = f->readable;
    fi.writable = f->writable;
    fi.ref = f->ref;
    release(&ftable.lock);

    // 2) Tìm các pid đang trỏ tới f (không giữ ftable.lock ở đây)
    for (struct proc *q = proc; q < &proc[NPROC]; q++) {
      acquire(&q->lock);
      if (q->state != UNUSED) {
        for (int fd = 0; fd < NOFILE; fd++) {
          if (q->ofile[fd] == f) {
            if (fi.npid < MAXPIDREF)
              fi.pids[fi.npid++] = q->pid;
            break; // mỗi pid chỉ liệt kê 1 lần dù dup nhiều fd
          }
        }
      }
      release(&q->lock);
    }

    // 3) copyout từng phần, vì mảng files[] quá lớn cho kernel stack
    uint64 dst = addr + offsetof(struct sysinfo, files) +
                 (uint64)n * sizeof(struct fileinfo);
    if (copyout(p->pagetable, p->sz, dst, (char *)&fi, sizeof(fi)) < 0)
      return -1;
    n++;
  }

  if (copyout(p->pagetable, p->sz, addr + offsetof(struct sysinfo, nfile),
              (char *)&n, sizeof(n)) < 0)
    return -1;
  return 0;
}

// Chỉ số của f trong ftable.file (B dùng trong fill_procinfo)
int
fileindex(struct file *f)
{
  return f - ftable.file;
}