#include "kernel/types.h"
#include "user.h"

int main(int argc, char * argv[]) {
    if (argc != 2) {
        printf("Incorrect parameters\n");
        return 0;
    }
    int duration = atoi(argv[1]);
    clogdur(duration);
    return 0;
}