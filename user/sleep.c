#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int arc, char *argv[]) {
    if (arc != 2)
    {
        fprintf(2, "No arg given!\n");
    }
    else {
        sleep(atoi(argv[1]));
    }  
    exit(0);
}