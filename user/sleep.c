#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    if(argc < 2){
        printf("usage: sleep tick count...\n");
        exit(1);
    }

    int value = atoi(argv[1]);

    int ret = pause(value);

    if(ret == -1){
        printf("Process exited\n");
    }

    exit(0);
}
