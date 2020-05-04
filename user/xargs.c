#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

int main(int argc, char *argv[])
{
  if(argc < 2) {
    fprintf(2, "usage: %s <command> [command arg]\n", argv[0]);
    exit(1);
  }
  char buf[256];
  gets(buf, sizeof(buf));
  buf[strlen(buf)-1] = 0;
  
  int pid = fork();
  if(pid > 0) {
    wait(0);    
  } else if(pid == 0){
    char *xargv[64];
    int i;
    for(i = 1; i < argc; i++) {
      xargv[i-1] = argv[i];
    }
    xargv[i-1] = buf;
    exec(xargv[0], xargv);
  } else {
    fprintf(2, "fork failed\n");
    exit(1);
  }

  exit(0);
}
