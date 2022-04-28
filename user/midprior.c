#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  for(;;){
    setp(2);
  };
  exit(0);
}
