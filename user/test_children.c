#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    printf("initial child count: %d\n", get_child_count());
    
    int pid1 = fork();
    if (pid1 == 0) {
        pause(5);
        exit(0);
    }

    printf("child_count after forking: %d\n", get_child_count());
    
    int pid2 = fork();
    if (pid2 == 0) {
        pause(5);
        exit(0);
    }

    printf("child_count after forking again: %d\n", get_child_count());
    
    int ppid = getppid();
    printf("child_count of pid %d: %d\n", ppid, get_process_child_count(ppid));
    
    wait(0);
    printf("child reaped. new child count: %d\n", get_child_count());
    
    wait(0);
    printf("child reaped. new child count: %d\n", get_child_count());
    
    exit(0);
}
