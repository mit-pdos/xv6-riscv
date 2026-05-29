#include "../kernel/types.h"
#include "../kernel/fcntl.h"
#include "user.h"

int main(int argc, char* argv[])
{
    if(argc <= 1) {
        fprintf(2, "Must enter time to execute sleep\n");
        return 1;
    }
    int time = atoi(argv[1]);
    pause(time);
    exit(0);
}