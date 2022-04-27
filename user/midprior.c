#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  for(;;){
    setp(2);
    /* printf("MIDPRIOR: Previous priority was %d \n", priority); */
  };
  exit(0);
}
