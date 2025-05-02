#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        fprintf(2, "Usage: %s <pid>\n", argv[0]);
        exit(1);
    }
    int pid = atoi(argv[1]);

    // Call freeze function
    int result = freeze(pid);
    if (result == 0)
    {
        printf("Process %d frozen successfully.\n", pid);
    }
    else if (result == -1)
    {
        printf("[ERROR] Memory allocation failure.\n");
    }
    else if (result == -2)
    {
        printf("[ERROR] No available slot to freeze the process with pid: %d.\n", pid);
    }
    else if (result == -3)
    {
        printf("[ERROR] Process already frozen for pid: %d.\n", pid);
    }
    else
    {
        printf("[ERROR] Unknown error occurred.\n");
    }

    return result;
}