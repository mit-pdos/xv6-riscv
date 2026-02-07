#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define N 4 // number of child processes
#define LOOP 50000000UL

void busy_work(int pid) {
    unsigned long i;
    for (i = 0; i < LOOP; i++) {
        // just burn CPU
    }
    printf("PID %d finished busy work\n", pid);
}

int main() {
    int i;

    printf("Starting %d CPU-bound processes with different nice values\n", N);

    for (i = 0; i < N; i++) {
        int pid = fork();
        if (pid < 0) {
            printf("fork failed\n");
            exit(1);
        }
        if (pid == 0) {
            // Child process
            // Set different nice values: higher i → lower priority
            int nice_val = i * 10 - 10; // -10, 0, 10, 20
            setnice(getpid(), nice_val);
            printf("Child PID %d set nice to %d\n", getpid(), nice_val);
            busy_work(getpid());
            exit(0);
        } else {
        }
    }

    // Parent waits for all children
    for (i = 0; i < N; i++) {
        wait(0);
    }

    printf("All children finished\n");
    exit(0);
}
