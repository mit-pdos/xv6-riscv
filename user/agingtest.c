#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int
main()
{
    printf("Starting aging test...\n");
    
    // Create multiple CPU-bound processes to test aging
    int pid1 = fork();
    if(pid1 == 0) {
        // Child process 1 - long CPU-bound task
        for(int i = 0; i < 1000000; i++) {
            if(i % 100000 == 0) {
                printf("Process 1: iteration %d\n", i);
            }
        }
        printf("Process 1 completed\n");
        exit(0);
    }
    
    int pid2 = fork();
    if(pid2 == 0) {
        // Child process 2 - another long CPU-bound task
        for(int i = 0; i < 1000000; i++) {
            if(i % 100000 == 0) {
                printf("Process 2: iteration %d\n", i);
            }
        }
        printf("Process 2 completed\n");
        exit(0);
    }
    
    // Parent process - wait for children and monitor
    printf("Parent: waiting for children...\n");
    wait(0);
    wait(0);
    
    printf("Aging test completed\n");
    exit(0);
}
