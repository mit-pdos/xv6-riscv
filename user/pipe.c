#include "../kernel/types.h"
#include "user.h"

char buf[512];

int main(int argc, char * argv[]) {
  int p[2], n;
  char* args[2] = {"wc", 0};
  pipe(p);
  int pid = fork();
  if (pid == 0) {
    close(0);
    dup(p[0]);
    close(p[0]);
    close(p[1]);
    exec("wc", args);
  } else {
    close(p[0]);
    n = read(0, buf, sizeof(buf));
    write(p[1], buf, n);
    close(p[1]);
    wait(0);
  }
  return 0;
}
