#ifndef __USER_PIPE_RT_H__
#define __USER_PIPE_RT_H__

int pipe_rt(int *fds);

typedef struct task_t {
  int priority;
  int x;
  int y;
  char op;
  int result;
  int error;
} task_t;


#endif
