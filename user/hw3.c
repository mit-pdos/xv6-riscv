#include "kernel/types.h"
#include "user.h"

int main() {
  int out; 
  int *address = malloc(4);

  pgaccess(address, 1, (char *)&out);                                        
  printf("pgaccess %p: %d\n", address, out); 

  pgaccess(address, 1, (char *)&out);                                        
  printf("pgaccess %p: %d\n", address, out); 

  *address = 2; //write checking -> access bit should be filled
  pgaccess(address, 1, (char *)&out);                                        
  printf("pgaccess %p: %d\n", address, out); 
  
  vmprint();
  exit(0);
}