#include "kernel/types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    int ppid = getppid();

    printf("Parent Process ID: %d\n", ppid);

    exit(1);
}