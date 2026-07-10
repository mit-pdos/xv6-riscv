#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static volatile uint64 spin_sink;

int
main(int argc, char *argv[])
{
  if (argc != 1) {
    fprintf(2, "usage: spin\n");
    exit(1);
  }

  for (;;)
    spin_sink++;

  exit(0);
}
