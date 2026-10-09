#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {

    interpose(atoi(argv[1]), argv[2]);

    printf("\n\nExec Arguments:\t");
    for (int i = 3; argv[i] != 0; i++) {
        printf("%s ", argv[i]);
    }
    printf("\n\n");

    exec(argv[3], argv + 3);    
    printf("sandbox failed!\n");

    return -1;
}