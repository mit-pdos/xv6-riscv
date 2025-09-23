#include "kernel/types.h" //include the types first
#include "user.h"

int main() {
  int pid = fork();
  if (pid < 0) {
    printf("Fork failed\n");
    exit(1);
  }else if (pid == 0) {
    // Child process
    printf("Hi, I am process: PID = %d, my parent is: PID = %d\n", getpid(), getppid());
    exit(0);
  } else {
    // Parent process
    wait(0); // Wait for child to finish
    printf("Hi, I am process: PID = %d, my son is: PID = %d\n", getpid(), pid);
  }
  exit(0);
}
