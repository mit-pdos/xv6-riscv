#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int
main()
{
    printf("Starting gaming test - attempting to stay at high priority...\n");
    
    // This process tries to game the scheduler by doing very short CPU bursts
    // followed by yielding voluntarily to try to maintain high priority
    
    int iterations = 0;
    while(iterations < 1000) {
        // Do minimal CPU work to appear productive but not CPU-bound
        int dummy = 0;
        for(int i = 0; i < 100; i++) {
            dummy += i;
        }
        
        // Voluntarily yield to try to maintain high priority
        // This is a classic gaming strategy
        yield();
        
        iterations++;
        
        // Report progress every 100 iterations
        if(iterations % 100 == 0) {
            printf("Gaming test: iteration %d completed\n", iterations);
        }
    }
    
    printf("Gaming test completed after %d iterations\n", iterations);
    printf("If allotment system works, this process should have been demoted\n");
    exit(0);
}
