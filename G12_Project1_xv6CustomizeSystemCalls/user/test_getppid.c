#include "kernel/types.h"
#include "user/user.h"

int main(){
    printf("My PID: %d\n", getpid());
    printf("Parent PID: %d\n", getppid());
    exit(0);
}
