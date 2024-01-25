#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"


int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <0 or 1>\n", argv[0]);
        exit(1);
    }

    int param = atoi(argv[1]);  // Convert argument to integer
    if (param != 0 && param != 1 && param != 2) {
        printf("Invalid argument. Please provide 0 or 1.\n");
        exit(1);
    }

    printf("Result: %d\n", sysinfo(param));

    exit(0);
}
