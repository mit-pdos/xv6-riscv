#include "kernel/types.h" //include the types first
#include "user.h"

int main() {
  printf("Hi, I am process : %d\n",getancestror(0));
  printf("My parent is : %d\n",getancestror(1));
  printf("My Grandfather is : %d\n",getancestror(2));
  //This should return -1 as my great grandfather does not exist, the kernel has 2 initial processes.
  printf("My Great Grandfather is : %d\n",getancestror(3));
  exit(0);
}
