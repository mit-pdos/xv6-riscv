#include "kernel/types.h"
#include "user/user.h"
#include "kernel/param.h"

int main(int argc, char *argv[])
{
  char buf[512], *p; 
  char *nargv[MAXARG]; 
  int rbytes, pid, status; 

  memset(nargv, 0, sizeof(nargv)); 
  memcpy(nargv, argv + 1, (argc - 1) * sizeof(argv[0])); 
  
  while (1)
  {
    p = buf; 
    while ((p - buf) < sizeof(buf) &&
       (rbytes = read(0, p, 1)) == 1 &&
       *p != '\n')
      p++;
    *p = 0; 
    if ((pid = fork()) < 0) 
    {
      fprintf(2, "xargs: fork failed\n");
      exit(1);
    }
    if (pid == 0)
    {
      nargv[argc - 1] = buf; 
      exec(nargv[0], nargv);     
    } 
    else 
    {
      wait(&status); 
      if (status < 0)
      {
        fprintf(2, "xargs: child process failed\n");
        exit(1);
      }
    }
    if (rbytes < 1)
      break; 
  }
  exit(0); 
}