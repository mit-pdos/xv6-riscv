#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  int original = getpriority();

  printf("Original priority: %d\n", original);

  if (setpriority(25) < 0) {
    printf("Failed to set priority\n");
    exit(1);
  }

  printf("Updated priority: %d\n", getpriority());

  if (setpriority(50) == -1) {
    printf("Invalid priority 50 rejected correctly\n");
  } else {
    printf("ERROR: Invalid priority accepted\n");
  }

  printf("Final priority: %d\n", getpriority());

  // Test priority inheritance.
  int pid = fork();

  if (pid < 0) {
    printf("Fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    printf("Child priority: %d\n", getpriority());
    exit(0);
  } else {
    wait(0);
    printf("Parent priority: %d\n", getpriority());
  }

  // Test priority boundaries.
  printf("Set priority 0: %d\n", setpriority(0));
  printf("Priority after setting 0: %d\n", getpriority());

  printf("Set priority 49: %d\n", setpriority(49));
  printf("Priority after setting 49: %d\n", getpriority());

  printf("Set priority -1: %d\n", setpriority(-1));
  printf("Priority after invalid value: %d\n", getpriority());

  exit(0);
}
