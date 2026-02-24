#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  setsched(2);  // SJN mode

  if(fork() == 0) {
    setburst(30);  // Long
    printf("P1 long start\n");
    pause(70);
    printf("P1 end\n");
    exit(0);
  }

  pause(5);  // Delay

  if(fork() == 0) {
    setburst(10);  // Short
    printf("P2 short start\n");
    pause(10);
    printf("P2 end\n");
    exit(0);
  }

  if(fork() == 0) {
    setburst(10);  // Short tie
    printf("P3 short tie start\n");
    pause(200);
    printf("P3 end\n");
    exit(0);
  }

  if(fork() == 0) {
    setburst(20);  // Medium
    printf("P4 medium start\n");
    pause(100);
    printf("P4 end\n");
    exit(0);
  }

  wait(0); wait(0); wait(0); wait(0);
  setsched(0);  // Reset
  exit(0);
}