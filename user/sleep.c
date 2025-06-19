#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
  if (argc != 2) {
    fprintf(2, "Usage: sleep <seconds>\n"); 
    exit(1); 
  }
  int seconds = atoi(argv[1]); 
  if (seconds < 0) {
    fprintf(2, "Error: sleep time must be a non-negative integer\n");
    exit(1);
  }
  sleep(seconds); 
  exit(0); 
}