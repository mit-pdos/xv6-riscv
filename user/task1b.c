#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void) {
    int PID = fork();
    if (PID == 0) {
        pause(150);
        exit(1);
    } else {
        printf("parent ID = %d\nchild ID = %d\n", getpid(), PID);
        kill(PID);
        int returnCode;
        int childID = wait(&returnCode);
        printf("childID = %d\nreturn code = %d\n", childID, returnCode);
    }

    exit(0);
}