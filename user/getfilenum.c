#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char **argv) {
  int i;
  if (argc < 2) {
    fprintf(2, "usage: getfilenum pid...\n");
    exit(1);
  }
  for (i = 1; i < argc; i++) {
    printf("%d\n", getfilenum(atoi(argv[i])));
  }
  exit(0);
}
