#include "kernel/types.h"
#include "user.h"

#define NULL 0
#define FD_STDERR 2

/// Convenient structure for a pipe,
/// containing read & write file descriptors of the pipe.
typedef struct {
  int read_fd;
  int write_fd;
} pipe_fds;

/// \return error code from "pipe" syscall
int open_pipe(pipe_fds *result) {
  int fds[2];
  int ret = pipe(fds);
  result->read_fd = fds[0];
  result->write_fd = fds[1];
  return ret;
}

void close_pipe(pipe_fds *pipe) {
  close(pipe->read_fd);
  close(pipe->write_fd);
}

typedef struct {
  pipe_fds forward;
  pipe_fds backward;
} two_end_pipe;

/// \return error code from "pipe" syscall
int open_two_end_pipe(two_end_pipe *pipe) {
  int ret = open_pipe(&pipe->forward);
  if (ret < 0)
    return ret;
  ret = open_pipe(&pipe->backward);
  if (ret < 0)
    close_pipe(&pipe->forward);
  return ret;
}

void close_two_end_pipe(two_end_pipe *pipe) {
  close_pipe(&pipe->forward);
  close_pipe(&pipe->backward);
}

/// Reports a fatal error and calls exit(1)
/// Does not return.
void fatal_error(const char *message) {
  fprintf(FD_STDERR, "Fatal: %s\n", message);
  exit(1);
}

/// Thread-safe
void print_recieved_char(int pid, char recieved, int mutex) {
  process_lock(SYS_PROCESS_LOCK_ACQUIRE, mutex);
  printf("%d: recieved %c\n", pid, recieved);
  process_lock(SYS_PROCESS_LOCK_RELEASE, mutex);
}

/// Continue as parent process.
/// Ownership of write_fd and read_fd and mutex is taken.
void parent(int write_fd, int read_fd, char *data, int mutex) {
  uint length = strlen(data);
  write(write_fd, data, length);
  close(write_fd);
  int my_pid = getpid();
  char current_char;
  while (read(read_fd, &current_char, 1)) {
    print_recieved_char(my_pid, current_char, mutex);
  }
  close(read_fd);
  process_lock(SYS_PROCESS_LOCK_FREE, mutex);
}

/// Continue as child process.
/// Ownership of read_fd and write_fd is taken.
void child(int read_fd, int write_fd, int mutex) {
  int my_pid = getpid();
  char current_char;
  while (read(read_fd, &current_char, 1)) {
    print_recieved_char(my_pid, current_char, mutex);
    write(write_fd, &current_char, 1);
  }
  close(read_fd);
  close(write_fd);
}

int main(int argc, char **argv) {
  if (argc <= 1)
    fatal_error("expected a second command line argument");

  two_end_pipe pipe;
  if (open_two_end_pipe(&pipe) < 0)
    fatal_error("unable to open a pipe");

  int mutex = process_lock(SYS_PROCESS_LOCK_ALLOCATE, 0);
  if (mutex < 0) {
    close_two_end_pipe(&pipe);
    fatal_error("unable to allocate process lock");
  }

  int fork_pid = fork();
  if (fork_pid < 0) {
    close_two_end_pipe(&pipe);
    fatal_error("unable to fork");
  } else if (fork_pid == 0) {
    close(pipe.forward.write_fd);
    close(pipe.backward.read_fd);
    child(pipe.forward.read_fd, pipe.backward.write_fd, mutex);
  } else { // fork_pid > 0
    close(pipe.forward.read_fd);
    close(pipe.backward.write_fd);
    parent(pipe.forward.write_fd, pipe.backward.read_fd, argv[1], mutex);
  }
  exit(0);
}

