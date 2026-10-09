#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {

    if (argc < 4) {
        return -1;
    }

    interpose(atoi(argv[1]), argv[2]);
    exec(argv[3], argv + 3);

    printf("sandbox failed!\n");
    return -1;
}