#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  int upto = 35;
  int p[35][2];
  int pipe_id = 0;

  pipe(p[0]);
  // root
  if(fork() > 0) {
    close(p[0][0]);
    for(int i = 2; i <= upto; i++) {
      if(write(p[0][1], &i, sizeof(i)) < 0) {
        fprintf(2, "write failed\n");
        exit(1);
      }
    }
    close(p[0][1]);
    wait(0);
  // child
  } else {
    int i, pid2 = -1;
    int div = 2;
    int is_forked = 0;
    pipe_id += 1;
    close(p[pipe_id-1][1]);
    printf("prime: 2\n");
    while(read(p[pipe_id-1][0], &i, sizeof(i)) > 0) {
      if(i % div != 0) {
        if(!is_forked) {
          pipe(p[pipe_id]);
          pid2 = fork();
          if(pid2 > 0) {
            printf("prime: %d\n", i);
            is_forked = 1;
            close(p[pipe_id][0]);
          } else {
            close(p[pipe_id-1][0]);
            close(p[pipe_id][1]);
            pipe_id += 1;
            div = i;
          }
        } else {
          write(p[pipe_id][1], &i, sizeof(i));
        }
      }
    }
    close(p[pipe_id-1][0]);
    close(p[pipe_id][1]);
    if(pid2 > 0)
      wait(0);
  }
  exit(0);
}

