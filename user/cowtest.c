#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int global = 42; // shared between parent and child

int main() {
    int pid = fork();
    if(pid == 0) {
        // child
        printf("child sees global = %d\n", global);
        global = 100;  // trigger COW
        printf("child changed global to %d\n", global);
        exit(0);
    } else {
        wait(0);
        printf("parent sees global = %d\n", global); // should still be 42
    }
    exit(0);
}
