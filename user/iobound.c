#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int
main()
{
    printf("Starting I/O-bound test...\n");
    
    // I/O-intensive work: repeated pause calls
    for(int i = 0; i < 20; i++) {
        printf("Iteration %d: pausing...\n", i);
        pause(10);  // Pause for 10 ticks
        printf("Iteration %d: resumed\n", i);
    }
    
    printf("I/O-bound test completed\n");
    exit(0);
}
