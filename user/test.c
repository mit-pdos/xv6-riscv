#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "user/user.h"

int main(int argc, char **argv)
{
  int p[5][2];
  
  pipe(p[0]);
  if(fork() > 0) {
    close(p[0][0]);
    close(p[0][1]);
    printf("root: wait()\n");
    wait(0);
  } else {
    close(p[0][1]);
    int a;
    if(read(p[0][0], &a, sizeof(a)) > 0) {
      printf("%d", a);
    } else {
      printf("-1\n");
    }
  }
  exit(0);
}
