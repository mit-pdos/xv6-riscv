#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int argc, char* argv[]) {
  // p1 from child to parent, p2 from parent to child
  int p1[2];
  int p2[2];

  char buf[1];

  pipe(p1);
  pipe(p2);

  int w_p;
  int r_p;
  int cycles = 0;
  int pid = fork();

  if (pid==0) {
    char byte = '1';
    buf[0] = byte;
    close(p1[0]);
    close(p2[1]);
    w_p = p1[1];
    r_p = p2[0];
    
    write(w_p, buf, 1);
  } else {   
    close(p1[1]);
    close(p2[0]);
    w_p = p2[1];
    r_p = p1[0];
  }

  while (1) {
    read(r_p, buf, 1);
    write(w_p, buf, 1);

    cycles++;
    if (pid!=0 && (cycles%1000==0)) {
      printf("Total Cycles: %d\n", cycles);
    }
  }
  exit(0);
}
