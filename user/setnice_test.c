#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    if(argc != 3){
        printf("Usage: setnice <pid> <nice>\n");
        exit(1);
    }

    int pid  = atoi(argv[1]);   // PID of the process to modify
    int nice = atoi(argv[2]);   // New nice value

    if(setnice(pid, nice) < 0){
        printf("setnice failed for PID %d\n", pid);
    } else {
        printf("Set nice of PID %d to %d\n", pid, nice);
    }

    exit(0);
}
