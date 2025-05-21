// test freeze with fork()
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int pid = fork();
    if (pid < 0)
    {
        printf("Fork failed\n");
        exit(1);
    }
    else if (pid == 0)
    {
        printf("[DEBUG] Child process PID: %d\n", pid);
        // Child process
        int i = 0;
        while (1)
        {
            i++;
            if (i % 100000000 == 0)
            {
                printf("[DEBUG] Child process running, i=%d\n", i);
            }
            // No syscalls in the loop, so timer interrupt can preempt
        }
    }
    else
    {
        sleep(10); // Give the child process some time to start
        printf("[DEBUG] Parent process PID: %d\n", pid);
        // Parent process
        // sleep(10); // Let the child run for a while
        // printf("[DEBUG] getallprocs from parent\n");
        // getallprocs();
        printf("[DEBUG] Freezing child process with PID: %d\n", pid);
        freeze(pid);
        getallprocs();
        sleep(100); // Keep the child frozen for a while
        printf("[DEBUG] Unfreezing child process with PID: %d\n", pid);
        unfreeze(pid);

        printf("[DEBUG] Parent process exiting\n");
        // wait(0);
        exit(0);
    }
    return 0;
}