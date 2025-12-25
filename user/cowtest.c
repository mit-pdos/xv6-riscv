#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int global = 42;

int main() {
    uint64 pa_parent_before, pa_child_before, pa_child_after;
    int pid;

    pa_parent_before = physaddr(&global);
    printf("parent physical page before fork: %lu\n", pa_parent_before);

    pid = fork();
    if(pid == 0) {
        pa_child_before = physaddr(&global);
        printf("child physical page before write: %lu\n", pa_child_before);

        global = 100;

        pa_child_after = physaddr(&global);
        printf("child physical page after write: %lu\n", pa_child_after);

        exit(0);
    } else {
        wait(0);
        uint64 pa_parent_after = physaddr(&global);
        printf("parent physical page after child exit: %lu\n", pa_parent_after);

        printf("parent sees global = %d\n", global);
    }
    exit(0);
}
