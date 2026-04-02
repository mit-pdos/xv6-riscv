#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int
main()
{
    printf("Starting legitimate I/O test - should maintain high priority...\n");
    
    // This process does legitimate I/O work - reads files and pauses
    // It should be able to maintain high priority due to I/O-bound behavior
    
    for(int iteration = 0; iteration < 10; iteration++) {
        printf("I/O test: iteration %d\n", iteration);
        
        // Simulate I/O work by pausing
        pause(20);  // Wait for 20 ticks
        
        // Do minimal CPU work between I/O operations
        int result = 0;
        for(int i = 0; i < 50; i++) {
            result += i;
        }
        
        // Force a context switch through legitimate I/O behavior
        // (not voluntary yield for gaming)
        pause(10);  // Another I/O wait
    }
    
    printf("Legitimate I/O test completed\n");
    printf("This process should have maintained good priority due to I/O behavior\n");
    exit(0);
}
