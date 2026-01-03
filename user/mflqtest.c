#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/pstat.h"
#include "user/user.h"

// CPU-bound process
void
cpu_bound(int id)
{
  int i, j;
  for(i = 0; i < 50000000; i++) {
    j = i * i;  // Just consume CPU
    if(i % 10000000 == 0) {
      printf("CPU-bound %d: iteration %d\n", id, i);
    }
  }
  exit(0);
}

// I/O-bound process
void
io_bound(int id)
{
  for(int i = 0; i < 100; i++) {
    printf("I/O-bound %d: iteration %d\n", id, i);
    sleep(10);  // Simulate I/O wait
  }
  exit(0);
}

int
main(int argc, char *argv[])
{
  int pid;
  
  printf("MLFQ Test Starting...\n");
  printf("Creating 2 CPU-bound and 2 I/O-bound processes\n\n");
  
  // Create CPU-bound processes
  for(int i = 0; i < 2; i++) {
    pid = fork();
    if(pid == 0) {
      cpu_bound(i);
    } else if(pid < 0) {
      printf("fork failed\n");
      exit(1);
    }
  }
  
  // Create I/O-bound processes
  for(int i = 0; i < 2; i++) {
    pid = fork();
    if(pid == 0) {
      io_bound(i);
    } else if(pid < 0) {
      printf("fork failed\n");
      exit(1);
    }
  }
  
  // Monitor processes
  struct pstat ps;
  for(int monitor = 0; monitor < 20; monitor++) {
    sleep(50);  // Wait a bit
    
    if(getpinfo(&ps) == 0) {
      printf("\n=== Process Status (iteration %d) ===\n", monitor);
      printf("PID\tPRIOR\tSTATE\t\tNAME\t\tTICKS\tWAIT\n");
      
      for(int i = 0; i < NPROC; i++) {
        if(ps.inuse[i] && ps.pid[i] > 2) {  // Skip init and sh
          printf("%d\t%d\t%s\t\t%s\t\t%d\t%d\n",
                 ps.pid[i],
                 ps.priority[i],
                 ps.state[i],
                 ps.name[i],
                 ps.ticks[i],
                 ps.wait_ticks[i]);
        }
      }
    }
  }
  
  // Wait for all children
  for(int i = 0; i < 4; i++) {
    wait(0);
  }
  
  printf("\nMLFQ Test Complete!\n");
  exit(0);
}