#include "user/user.h"

int
main(void)
{
    int i;
    for(i = 0; i < 5000000000; i++);  // Busy loop to consume CPU
    printf("program1 done\n");
    exit(0);
}
