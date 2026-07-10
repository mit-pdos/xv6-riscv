#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static volatile uint64 spin_sink;

#define SPIN_BURST 1000000

int
main(int argc, char *argv[])
{
  int i;

  if (argc != 1) {
    fprintf(2, "usage: spin\n");
    exit(1);
  }

  for (;;) {
    for (i = 0; i < SPIN_BURST; i++)
      spin_sink++;
    pause(1);
  }

  exit(0);
}
