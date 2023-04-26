#include "kernel/types.h"
#include "user.h"

int main(int argc, char * argv[]) {
    if (argc != 2 || strlen(argv[1]) != 1) {
        printf("Incorrect parameters\n");
        return 0;
    }
    int mask = argv[1][0] - '0';
    if (mask < 0 || mask > 7) {
        printf("Mask should be from 0 to 7, since:\n",
            "1-st bit for interrupt logging,\n", 
            "2-nd bit for context switching logging,\n", 
            "3-rd bit for system calls logging\n");
        return 0;
    }
    cloglev(mask);
    return 0;
}