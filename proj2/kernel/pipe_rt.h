#ifndef __PIPE_RT_H__
#define __PIPE_RT_H__

#include "spinlock.h"

#define PIPE_TASKS 16

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
