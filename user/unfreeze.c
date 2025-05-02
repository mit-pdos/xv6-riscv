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
    int result = unfreeze(pid);
    if (result == 0)
    {
        printf("Process %d unFrozen successfully.\n", pid);
    }
    else if (result == -1)
    {
        printf("[ERROR] Process %d not found.\n", pid);
    }
    else if (result == -2)
    {
        printf("[ERROR] Process %d not frozen.\n", pid);
    }
    else
    {
        printf("[ERROR] Unknown error occurred.\n");
    }

    return result;
}