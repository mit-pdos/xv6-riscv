#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// ---------- 1. Fork Bomb (Limited) ----------
void test_fork_bomb(void) {
  printf("\n[TEST] Fork bomb (limited)\n");

  int count = 0;

  while (count < 30) {
    int pid = fork();

    if (pid < 0) {
      printf("Fork failed at %d\n", count);
      break;
    } else if (pid == 0) {
      for (int i = 0; i < 100; i++); // small work
      exit(0);
    }

    count++;
  }

  while (wait(0) > 0);
  printf("Fork bomb test done\n");
}

// ---------- 2. Max Process Test ----------
void test_max_process(void) {
  printf("\n[TEST] Maximum process count\n");

  int count = 0;

  while (1) {
    int pid = fork();

    if (pid < 0) {
      printf("Max processes reached at %d\n", count);
      break;
    } else if (pid == 0) {
      sleep(50);  // keep process alive
      exit(0);
    }

    count++;
  }

  while (wait(0) > 0);
  printf("Max process test done\n");
}

// ---------- 3. Rapid Fork/Exit ----------
void test_rapid_fork_exit(void) {
  printf("\n[TEST] Rapid fork/exit\n");

  for (int i = 0; i < 100; i++) {
    int pid = fork();

    if (pid == 0) {
      exit(0);
    } else {
      wait(0);
    }
  }

  printf("Rapid fork/exit test done\n");
}

// ---------- 4. Priority Starvation (Simulation) ----------
void test_starvation(void) {
  printf("\n[TEST] Starvation simulation\n");

  // Long CPU process
  if (fork() == 0) {
    printf("Long CPU process started\n");
    for (int i = 0; i < 100000000; i++);
    printf("Long CPU process finished\n");
    exit(0);
  }

  // Many short processes
  for (int i = 0; i < 10; i++) {
    if (fork() == 0) {
      printf("Short job %d\n", getpid());
      sleep(5);
      exit(0);
    }
  }

  while (wait(0) > 0);
  printf("Starvation test done\n");
}

// ---------- 5. Deadlock Detection (Simple Simulation) ----------
void test_deadlock(void) {
  printf("\n[TEST] Deadlock simulation (sleep-based)\n");

  int pid = fork();

  if (pid == 0) {
    // Child waits forever (simulating blocked state)
    printf("Child waiting...\n");
    sleep(100);
    exit(0);
  } else {
    printf("Parent waiting...\n");
    sleep(100);
    wait(0);
  }

  printf("Deadlock test done\n");
}

// ---------- MAIN ----------
int main(int argc, char *argv[]) {

  printf("=== Scheduler Stress Test Start ===\n");

  test_fork_bomb();
  test_max_process();
  test_rapid_fork_exit();
  test_starvation();
  test_deadlock();

  printf("\n=== All tests completed ===\n");

  exit(0);
}