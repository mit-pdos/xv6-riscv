#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  setsched(1);  // FCFS mode

  if(fork() == 0) {
    printf("P1 (arrive first, short) start\n");
    pause(10);  // Short burst
    printf("P1 end\n");
    exit(0);
  }

  pause(5);  // Delay P2 arrival

  if(fork() == 0) {
    printf("P2 (later, long) start\n");
    for(volatile int i = 0; i < 1000000000; i++);  // Long busy loop
    printf("P2 end\n");
    exit(0);
  }

  if(fork() == 0) {
    printf("P3 (latest, medium) start\n");
    pause(20);
    printf("P3 end\n");
    exit(0);
  }

  wait(0); wait(0); wait(0);
  setsched(0);  // Back to default
  exit(0);
}