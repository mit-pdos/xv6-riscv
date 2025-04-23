#include "kernel/types.h"
#include "user/user.h"
#include "pipe_rt.h"

#define NUM_CLIENTS 4
#define MAXCLIENTS 16

typedef struct {
  int x, y;
  char op;
  int expected_result;
  int expected_error;
  int priority;
} TestCase;

TestCase test_cases[] = {
  {10, 4, '-', 6, 0, 2},
  {34, 9, '+', 43, 0, 1},
  {56, 6, '&', 0, -1, 3},  // Invalid operator
  {5, 0, '/', 0, -1, 0},   // Division by zero
};

// Append an integer with optional prefix to buffer
int append_int(char *dst, const char *prefix, int val) {
  int i = 0, j = 0, len = 0;
  char buf[16];

  while (prefix[j]) dst[len++] = prefix[j++];

  if (val == 0) {
    dst[len++] = '0';
    return len;
  }

  if (val < 0) {
    dst[len++] = '-';
    val = -val;
  }

  while (val > 0) {
    buf[i++] = (val % 10) + '0';
    val /= 10;
  }

  while (i > 0) dst[len++] = buf[--i];
  return len;
}

void client(int write_fd, int read_fd, int result_fd, task_t t, int id, int expected_result, int expected_error) {
  write(write_fd, &t, sizeof(t));
  close(write_fd);

  read(read_fd, &t, sizeof(t));
  close(read_fd);

  char buf[256];
  int len = 0;

  len += append_int(buf + len, "Task ", id);
  buf[len++] = ':';
  buf[len++] = ' ';
  buf[len++] = '(';
  len += append_int(buf + len, "", t.x);
  buf[len++] = ' ';
  buf[len++] = t.op;
  buf[len++] = ' ';
  len += append_int(buf + len, "", t.y);
  buf[len++] = ')';
  len += append_int(buf + len, ". Expected: ", expected_result);
  buf[len++] = ',';
  buf[len++] = ' ';
  len += append_int(buf + len, "", expected_error);
  buf[len++] = ',';
  buf[len++] = ' ';
  len += append_int(buf + len, "Received: ", t.result);
  buf[len++] = ',';
  buf[len++] = ' ';
  len += append_int(buf + len, "", t.error);

  const char *res = (t.result == expected_result && t.error == expected_error) ? ". PASS\n" : ". FAIL\n";
  for (int i = 0; res[i]; i++) buf[len++] = res[i];

  write(result_fd, buf, len);
  exit(0);
}

int calc(int x, int y, char op, int *res) {
  switch (op) {
    case '+': *res = x + y; return 0;
    case '-': *res = x - y; return 0;
    case '*': *res = x * y; return 0;
    case '/': if (y == 0) return -1; *res = x / y; return 0;
    default: return -1;
  }
}

void server_multi(int c2s[][2], int s2c[][2], int n) {
  int client_active[MAXCLIENTS], active = n;
  for (int i = 0; i < n; i++) client_active[i] = 1;

  task_t t;

  while (active > 0) {
    for (int i = 0; i < n; i++) {
      if (!client_active[i]) continue;
      int r = read(c2s[i][0], &t, sizeof(t));
      if (r == sizeof(t)) {
        t.error = calc(t.x, t.y, t.op, &t.result);
        write(s2c[i][1], &t, sizeof(t));
      } else {
        client_active[i] = 0;
        active--;
        close(c2s[i][0]);
        close(s2c[i][1]);
      }
    }
  }

  exit(0);
}

int main() {
  int c2s[NUM_CLIENTS][2], s2c[NUM_CLIENTS][2], result_pipe[2];
  pipe(result_pipe);

  for (int i = 0; i < NUM_CLIENTS; i++) {
    if (pipe_rt(c2s[i]) < 0 || pipe(s2c[i]) < 0) {
      write(1, "pipe setup failed\n", 19);
      exit(1);
    }
  }

  for (int i = 0; i < NUM_CLIENTS; i++) {
    if (fork() == 0) {
      for (int j = 0; j < NUM_CLIENTS; j++) {
        if (j != i) {
          close(c2s[j][0]); close(c2s[j][1]);
          close(s2c[j][0]); close(s2c[j][1]);
        }
      }
      close(result_pipe[0]);
      task_t t = {test_cases[i].priority, test_cases[i].x, test_cases[i].y, test_cases[i].op, 0, 0};
      client(c2s[i][1], s2c[i][0], result_pipe[1], t, i, test_cases[i].expected_result, test_cases[i].expected_error);
    }
  }

  for (int i = 0; i < NUM_CLIENTS; i++) {
    close(c2s[i][1]); close(s2c[i][0]);
  }
  close(result_pipe[1]);

  if (fork() == 0) server_multi(c2s, s2c, NUM_CLIENTS);

  char buf[256];
  int n;
  while ((n = read(result_pipe[0], buf, sizeof(buf))) > 0) {
    write(1, buf, n);
  }

  for (int i = 0; i < NUM_CLIENTS + 1; i++) wait(0);
  exit(0);
}