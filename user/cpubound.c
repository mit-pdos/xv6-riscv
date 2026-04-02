#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int
main()
{
    printf("Starting CPU-bound test...\n");
    
    // CPU-intensive work: calculate primes
    int count = 0;
    int limit = 10000;
    
    for(int n = 2; n <= limit; n++) {
        int is_prime = 1;
        for(int i = 2; i*i <= n; i++) {
            if(n % i == 0) {
                is_prime = 0;
                break;
            }
        }
        if(is_prime) {
            count++;
        }
    }
    
    printf("Found %d primes up to %d\n", count, limit);
    printf("CPU-bound test completed\n");
    exit(0);
}
