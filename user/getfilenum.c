#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int fd1=0;
int fd2=0;
int fd3=0;
int fd4=0;
int fd5=0;
void openFive()
{
    fd1 = open("gfilenumtest1", O_CREATE|O_WRONLY);
    fd2 = open("gfilenumtest2", O_CREATE|O_WRONLY);
    fd3 = open("gfilenumtest3", O_CREATE|O_WRONLY);
    fd4 = open("gfilenumtest4", O_CREATE|O_WRONLY);
    fd5 = open("gfilenumtest5", O_CREATE|O_WRONLY);
}
int
main(int argc, char **argv)
{
  int pid = getpid();

  printf("files open for %d\n:",pid);
  printf("before opening any additional: %d (should be 3)\n",getfilenum(pid));
  openFive();
  printf("opened 5: %d (should be 8)\n",getfilenum(pid));
  close(fd3);
  printf("closed 1: %d (should be 7)\n",getfilenum(pid));
  close(fd1);
  printf("closed another: %d (should be 6)\n",getfilenum(pid));
  close(fd5);
  printf("closed another: %d (should be 5)\n",getfilenum(pid));
  fd5 = open("gfilenmumtest6", O_CREATE|O_WRONLY);
  printf("opened 1: %d (should be 6)\n",getfilenum(pid));
  close(fd5);
  close(fd2);
  close(fd4);
  printf("closed all: %d (should be 3)\n",getfilenum(pid));
  exit(0);
}
