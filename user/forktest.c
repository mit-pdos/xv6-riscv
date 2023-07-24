// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define N  1000

void
print(const char *s)
{
  write(1, s, strlen(s));
}

void
forktest(void)
{
  int n, pid, status;

  print("fork test\n");

  for(n=0; n<N; n++){
    pid = fork();
    if(pid < 0){
      if(errno == ENOMEM){
        print("fork claimed to work N times!\n");
        exit(1);
      }else{
        print("fork failed\n");
        exit(1);
      }
    }
    if(pid == 0)
      exit(0);
  }

  for(; n > 0; n--){
    if(wait(&status) < 0){
      print("wait stopped early\n");
      exit(1);
    }
    if(status != 0){
      print("child exited with status %d\n", status);
      exit(1);
    }
  }

  print("fork test OK\n");
}

int
main(void)
{
  signal(SIGINT, SIG_IGN);
  forktest();
  exit(0);
}
