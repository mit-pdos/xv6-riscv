#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
    int year = getyear();

    printf("Kernel says year = %d\n", year);

    exit(0);
}
