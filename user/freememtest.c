#include "kernel/types.h"
#include "user/user.h"
int main(void) {
    int free = freemem();
    printf("Free memory: %d bytes\n", free);
    exit(0);
}