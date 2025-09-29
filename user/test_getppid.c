#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    int ppid = getppid();
    printf("Mi PID padre es: %d\n", ppid);
    exit(0);
}