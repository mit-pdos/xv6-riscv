#include "kernel/types.h"
#include "user/user.h"

void wait_a_bit(void) {
  volatile long x = 0;
  for(long i = 0; i < 10000000; i++) x++;
}

int main(void) {
  for(int i = 0; i < 4; i++){
    if(fork() == 0){
      setheatclass(2);
      volatile long x = 0;
      while(1) x++;
    }
  }

  for(int i = 0; i < 20; i++){
    printf("cpu_temp = %d\n", gettemp());
    wait_a_bit();
  }

  exit(0);
}
