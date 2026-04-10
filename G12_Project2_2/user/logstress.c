#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

// Stress xv6 logging system by having several processes writing
// concurrently to their own file (e.g., logstress f1 f2 f3 f4)

#define BUFSZ 500

char buf[BUFSZ];

int
main(int argc, char **argv)
{
  int fd, n;
  enum { N = 250, SZ=2000 };
  
  for (int i = 1; i < argc; i++){
    int pid1 = fork();
    if(pid1 < 0){
      printf("%s: fork failed\n", argv[0]);
      exit(1);
    }
    if(pid1 == 0) {
      fd = open(argv[i], O_CREATE | O_RDWR);
      if(fd < 0){
        printf("%s: create %s failed\n", argv[0], argv[i]);
        exit(1);
      }
      memset(buf, '0'+i, SZ);
      for(i = 0; i < N; i++){
        if((n = write(fd, buf, SZ)) != SZ){
          printf("write failed %d\n", n);
          exit(1);
        }
      }
      exit(0);
    }
  }
  int xstatus;
  for(int i = 1; i < argc; i++){
    wait(&xstatus);
    if(xstatus != 0)
      exit(xstatus);
  }
  return 0;
}
