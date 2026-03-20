#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int start_time, current_time, elapsed;
  int target_duration = 1000;  // ~10 seconds (assuming 100 ticks/second)
  int sleep_interval = 200;     // ~2 seconds between prints
  
  // Get the starting time in ticks
  start_time = uptime();
  
  printf("myproc: Starting process...\n");
  
  // Run for approximately 10 seconds
  while(1) {
    current_time = uptime();
    elapsed = current_time - start_time;
    
    // Check if we've reached our target duration
    if(elapsed >= target_duration) {
      break;
    }
    
    // Print status message
    printf("Running process...\n");
    
    // Sleep to avoid busy waiting
    pause(sleep_interval);
  }
  
  printf("myproc: Process completed.\n");
  exit(0);
}
