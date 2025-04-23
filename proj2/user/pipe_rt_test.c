#include "kernel/types.h"
#include "user/user.h"
#include "pipe_rt.h"

int pipe_rt(int *fds);

void server(int fd) {
  task_t t;
  while (read(fd, &t, sizeof(t)) > 0) {
    switch (t.op) {
      case '+': t.result = t.x + t.y; t.error = 0; break;
      case '-': t.result = t.x - t.y; t.error = 0; break;
      case '*': t.result = t.x * t.y; t.error = 0; break;
      case '/': if (t.y == 0) t.error = -1; else { t.result = t.x / t.y; t.error = 0; } break;
      default: t.error = -1;
    }
    printf("Handled task: (%d %c %d) = %d [priority: %d]\n", t.x, t.op, t.y, t.result, t.priority);
  }
  exit(0);
}

void client(int fd, task_t task) {
  write(fd, &task, sizeof(task));
  exit(0);
}

int main() {
  int fds[2];
  if (pipe_rt(fds) < 0) {
    printf("pipe_rt failed\n");
    exit(1);
  }

  task_t tasks[3] = {
    {3, 10, 5, '+', 0, 0},
    {1, 7, 0, '/', 0, 0},
    {5, 20, 4, '*', 0, 0}
  };

  for (int i = 0; i < 3; i++) {
    if (fork() == 0) {
      client(fds[1], tasks[i]);
    }
  }

  server(fds[0]);

  for (int i = 0; i < 3; i++) wait(0);
  exit(0);
}
