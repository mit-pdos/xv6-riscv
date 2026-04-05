#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int n_cpu = 3;
  int n_io = 3;
  int delay = 2;   // arrival delay (ticks)

  // ---------- Configurable Inputs ----------
  if (argc >= 3) {
    n_cpu = atoi(argv[1]);
    n_io = atoi(argv[2]);
  }

  if (argc >= 4) {
    delay = atoi(argv[3]);
  }

  printf("=== Mixed Benchmark Start ===\n");
  printf("CPU: %d, IO: %d, Delay: %d\n", n_cpu, n_io, delay);

  int start_total = uptime();

  // ---------- Spawn CPU-bound ----------
  for (int i = 0; i < n_cpu; i++) {
    int pid = fork();

    if (pid == 0) {
      

      printf("[CPU %d] started\n", getpid());

      char *args[] = {"cpubench", "prime", 0};
      exec("cpubench", args);

      // If exec fails
      printf("[CPU %d] exec failed\n", getpid());
      exit(1);
    }

    sleep(delay);  // arrival pattern
  }

  // ---------- Spawn IO-bound ----------
  for (int i = 0; i < n_io; i++) {
    int pid = fork();

    if (pid == 0) {
    
      printf("[IO %d] started\n", getpid());

      char *args[] = {"iobench", 0};
      exec("iobench", args);

      printf("[IO %d] exec failed\n", getpid());
      exit(1);
    }

    sleep(delay);  // arrival pattern
  }

  // ---------- Wait for all ----------
  for (int i = 0; i < n_cpu + n_io; i++) {
    wait(0);
  }

  int end_total = uptime();

  // ---------- Summary ----------
  printf("\n===== SUMMARY =====\n");
  printf("CPU processes: %d\n", n_cpu);
  printf("IO processes: %d\n", n_io);
  printf("Total processes: %d\n", n_cpu + n_io);
  printf("Total execution time: %d ticks\n", end_total - start_total);

  printf("=== Mixed Benchmark End ===\n");

  exit(0);
}