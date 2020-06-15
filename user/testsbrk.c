#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char **argv)
{
  char *a = 0;
  a = sbrk(1);
  printf("addr: %p\n", a);
  a = sbrk(2);
  printf("addr: %p\n", a);
  exit(0);
}
