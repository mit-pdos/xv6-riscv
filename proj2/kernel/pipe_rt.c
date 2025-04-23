#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"      
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "proc.h"
#include "fs.h"
#include "file.h"
#include "pipe_rt.h"

int pipe_rt(int *fds) {
  struct file *rf, *wf;
  struct pipe_rt *p;

  p = (struct pipe_rt*)kalloc();
  if (p == 0) return -1;
  initlock(&p->lock, "pipe_rt");
  p->readopen = 1;
  p->writeopen = 1;
  p->task_count = 0;

  rf = filealloc();
  wf = filealloc();
  if (rf == 0 || wf == 0) goto fail;

  rf->type = FD_PIPE;
  rf->readable = 1;
  rf->writable = 0;
  rf->pipe_rt = p;

  wf->type = FD_PIPE;
  wf->readable = 0;
  wf->writable = 1;
  wf->pipe_rt = p;

  int fd0 = fdalloc(rf), fd1 = fdalloc(wf);
  if (fd0 < 0 || fd1 < 0) goto fail;

  fds[0] = fd0;
  fds[1] = fd1;
  return 0;

fail:
  if (rf) fileclose(rf);
  if (wf) fileclose(wf);
  kfree((void*)p);
  return -1;
}

uint64
sys_pipe_rt(void)
{
  uint64 addr;
  argaddr(0, &addr);
  int fds[2];
  if (pipe_rt(fds) < 0)
    return -1;
  if (copyout(myproc()->pagetable, addr, (char *)fds, sizeof(fds)) < 0)
    return -1;
  return 0;
}
