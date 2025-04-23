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

static int fdalloc(struct file *f);

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

  rf->type = FD_PIPE_RT;
  rf->readable = 1;
  rf->writable = 0;
  rf->pipe_rt = p;

  wf->type = FD_PIPE_RT;
  wf->readable = 0;
  wf->writable = 1;
  wf->pipe_rt = p;

  //printf("DEBUG: rf->type=%d, wf->type=%d\n", rf->type, wf->type); 

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

static int
fdalloc(struct file *f)
{
  struct proc *p = myproc();
  for (int fd = 0; fd < NOFILE; fd++) {
    if (p->ofile[fd] == 0) {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}

int pipe_rt_read(struct pipe_rt *p, uint64 addr, int n)
{
  //printf("DEBUG pipe_rt_read: task_count = %d\n", p->task_count);

  acquire(&p->lock);
  if (p->task_count > 0 && n >= sizeof(task_t)) {
    task_t task = p->queue[0];
    for (int i = 1; i < p->task_count; i++) {
      p->queue[i - 1] = p->queue[i];
    }
    p->task_count--;
    release(&p->lock);
    if (copyout(myproc()->pagetable, addr, (char*)&task, sizeof(task)) < 0)
      return -1;
    return sizeof(task);
  }

  if (p->writeopen == 0 && p->task_count == 0) {
    release(&p->lock);
    return 0;
  }

  release(&p->lock);
  return -1;
}


int
pipe_rt_write(struct pipe_rt *p, uint64 addr, int n)
{
  if (n != sizeof(task_t)){
    //printf("pipe_rt_write: wrong size\n");
    return -1;
  }

  task_t task;
  if (copyin(myproc()->pagetable, (char*)&task, addr, sizeof(task)) < 0){
    //printf("pipe_rt_write: copyin failed\n");
    return -1;
  }

  acquire(&p->lock);
  if (p->task_count < PIPE_TASKS) {
    int i = p->task_count++;
    while (i > 0 && p->queue[i - 1].priority < task.priority) {
      p->queue[i] = p->queue[i - 1];
      i--;
    }
    p->queue[i] = task;
    //printf("pipe_rt_write: inserted task priority %d\n", task.priority);
    release(&p->lock);
    return sizeof(task);
  }
  //printf("pipe_rt_write: queue full\n");
  release(&p->lock);
  //printf("DEBUG pipe_rt_write: wrote task with priority %d\n", task.priority);

  return -1;  
}

void
pipe_rt_close(struct pipe_rt *p, int writable)
{
  acquire(&p->lock);
  if (writable) {
    p->writeopen = 0;
  } else {
    p->readopen = 0;
  }

  if (p->readopen == 0 && p->writeopen == 0) {
    release(&p->lock);
    kfree((void*)p);
  } else {
    release(&p->lock);
  }
}