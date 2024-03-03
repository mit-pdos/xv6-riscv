#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char **argv) {
    int pid = fork();
    if (pid == 0) {
        sleep(50);
        exit(1);
    }
    else if (pid > 0) {
        int parentID = getpid();
        int childID = pid;
        printf("Parent id: %d\n", parentID);
        printf("Child id: %d\n", childID);
        int status;
        pid = wait(&status);
        printf("Child process %d is terminated with %d status code\n", childID, status);
        exit(0);
    }
    else {
        fprintf(2, "Error: can't start new process\n");
        exit(1);
    }
}