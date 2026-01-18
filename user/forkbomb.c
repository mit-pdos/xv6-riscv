#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int start = uptime();

  // wait ~20 ticks so shell detaches
  while(uptime() - start < 20)
    ;

  while(1){
    fork();
  }
}

