#ifndef __PIPE_RT_H__
#define __PIPE_RT_H__

#define PIPE_TASKS 16


int pipe_rt_read(struct pipe_rt *p, uint64 addr, int n);
int pipe_rt_write(struct pipe_rt *p, uint64 addr, int n);
void pipe_rt_close(struct pipe_rt *p, int writable);


typedef struct task_t {
  int priority;
  int x;
  int y;
  char op;
  int result;
  int error;
} task_t;

struct pipe_rt {
  struct spinlock lock;
  int readopen;
  int writeopen;
  task_t queue[PIPE_TASKS];
  int task_count;
};

#endif
