#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  char* time = argv[1];
  int itime = atoi(time);

  if (!time) { printf("Error, parameter required\n"); }

  pause(itime);

  exit(0);
}
