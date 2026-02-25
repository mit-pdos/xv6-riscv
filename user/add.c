#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[]) {
  const int buf_size = 100;
  char buf[buf_size];
  int n, x, y;

  int first_space = -1;
  int str_len = 0;
  for (int i = 0; i < buf_size; ++i) {
    n = read(0, buf + i, 1);
    if (n <= 0) {
      break;
    }
    if (buf[i] == ' ') {
      if (first_space != -1) {
        fprintf(2, "add: should have exactly one space\n");
        exit(1);
      }
      first_space = i;
    }

    if (buf[i] == '\n') {
      buf[i] = '\0';
      break;
    }
    str_len++;
  }

  buf[str_len] = '\0';

  if (first_space == -1 || first_space == 0) {
    fprintf(2, "add: should have 2 arguments\n");
    exit(1);
  }

  for (int i = 0; i < str_len; ++i) {
    if (!(buf[i] == ' ' || ('0' <= buf[i] && buf[i] <= '9'))) {
      fprintf(2, "add: should contains digits only\n");
      exit(1);
    }
  }

  x = atoi(buf);
  y = atoi(buf + first_space + 1);

  int res = add(x, y);
  printf("|%s|\n", buf);
  printf("%d\n", res);
  exit(0);
}
