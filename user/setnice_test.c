#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    int pid = fork();
    if(pid < 0){
        printf("fork failed\n");
        exit(1);
    }

    if(pid == 0){
        // Child: busy loop
        for(int i = 0; i < 1000000; i++);
        printf("Child finished\n");
        exit(0);
    } else {
        // Parent: change child's nice value
        printf("Parent: setting child nice to 10\n");
        setnice(pid, 10);

        // wait for child
        wait(0);
        printf("Parent: child exited\n");
        exit(0);
    }
}
