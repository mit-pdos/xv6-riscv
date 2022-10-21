#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"


#define NFORK 10
#define IO 5

int main() {
  int n, pid;
  int wtime, rtime;
  int twtime=0, trtime=0;
  for (n=0; n < NFORK;n++) {
      pid = fork();
      if (pid < 0)
          break;
      if (pid == 0) {
          if (n < IO) {
            sleep(250); // IO bound processes
          } else {
            for (uint64 i = 0; i < 10000000000; i++) {}; // CPU bound process
          }
          printf("Process %d finished\n", n);
          exit(0);
      } else {
#ifdef LBS
          settickets((n+1)*(n+1)*(n+1));
#endif
#ifdef PBS
        set_priority(60-IO-n, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
      if(waitx(0,&wtime,&rtime) >= 0) {
          trtime += rtime;
          twtime += wtime;
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  exit(0);
}
