// Test program for MLFQ scheduler
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void
cpu_intensive(int id)
{
  int i, j;
  volatile int x = 0;  // Prevent optimization
  printf("CPU-intensive process %d starting\n", id);
  for(i = 0; i < 100000; i++) {
    for(j = 0; j < 100; j++) {
      x = x + 1;  // Busy work
    }
  }
  printf("CPU-intensive process %d done (x=%d)\n", id, x);
  exit(0);
}

void
io_intensive(int id)
{
  int i;
  char buf[10];
  printf("I/O-intensive process %d starting\n", id);
  for(i = 0; i < 20; i++) {
    // Simulate I/O by reading from console (will block briefly)
    int fd = open("README", 0);
    if(fd >= 0) {
      read(fd, buf, sizeof(buf));
      close(fd);
    }
    printf("I/O process %d iteration %d\n", id, i);
  }
  printf("I/O-intensive process %d done\n", id);
  exit(0);
}

int
main(int argc, char *argv[])
{
  int pid;
  
  printf("MLFQ Scheduler Test\n");
  printf("Creating 3 CPU-intensive and 3 I/O-intensive processes\n\n");
  
  // Create 3 CPU-intensive processes
  for(int i = 0; i < 3; i++) {
    pid = fork();
    if(pid == 0) {
      cpu_intensive(i);
    } else if(pid < 0) {
      printf("fork failed\n");
      exit(1);
    }
  }
  
  // Create 3 I/O-intensive processes
  for(int i = 0; i < 3; i++) {
    pid = fork();
    if(pid == 0) {
      io_intensive(i);
    } else if(pid < 0) {
      printf("fork failed\n");
      exit(1);
    }
  }
  
  // Wait for all children
  for(int i = 0; i < 6; i++) {
    wait(0);
  }
  
  printf("\nAll processes completed\n");
  exit(0);
}
