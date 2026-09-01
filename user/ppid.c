#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    int pid = getpid();

    printf("[parent] my pid is %d\n", pid);
    printf("[parent] forking a child process\n");

    int child = fork();

    if (child == 0) {
        printf("[child] my pid is %d\n", getpid());
        printf("[child] my parent is %d\n", getppid());
        exit(0);
    } else {
        wait(0);
    }

    exit(0);
}
