#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[]) {
  int x1 = settickets(10);
  int x2 = settickets(0);
  fprintf(1, "XV6_TEST_OUTPUT %d %d\n", x1, x2);
  exit(0);
}
