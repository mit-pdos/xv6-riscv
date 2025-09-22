#include "kernel/types.h" //include the types first
#include "user.h"

int main() {
  int pid = fork();
  if (pid < 0) {
    printf("Fork failed\n");
    exit(1);
  }else if (pid == 0) {
    // Child process
    printf("Child process: PID = %d, Parent PID = %d\n", getpid(), getppid());
    exit(0);
  } else {
    // Parent process
    wait(0); // Wait for child to finish
    printf("Parent process: PID = %d, Child PID = %d\n", getpid(), pid);
    printf("Hi, I am process : %d, my Grandfather is : %d\n",getpid(),getancestror(2));
  }
  exit(0);
}
