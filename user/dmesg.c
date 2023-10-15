#include "kernel/types.h"
#include "user/user.h"

#define USER_BUFFER_SIZE (1 << 10)

int main() {
  static const char buffer[USER_BUFFER_SIZE];
  dmesg(buffer, USER_BUFFER_SIZE);
  printf("%s", buffer);
  exit(0);
}