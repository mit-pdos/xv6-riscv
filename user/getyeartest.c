#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
    printf("Kernel says year = %d\n", getyear());
    exit(0);
}