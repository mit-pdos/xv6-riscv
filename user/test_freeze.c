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
        // Child process
        while (1)
        {
            // printf("[DEBUG] Child process running\n");
            getallprocs();
            sleep(10);
        }
    }
    else
    {
        // Parent process
        sleep(10); // Let the child run for a while
        printf("[DEBUG] getallprocs from parent\n");
        getallprocs();
        printf("[DEBUG] Freezing child process with PID: %d\n", pid);
        freeze(pid);
        sleep(10); // Keep the child frozen for a while
        printf("[DEBUG] Unfreezing child process with PID: %d\n", pid);
        unfreeze(pid);

        printf("[DEBUG] Parent process exiting\n");

        exit(0);
    }
    return 0;
}