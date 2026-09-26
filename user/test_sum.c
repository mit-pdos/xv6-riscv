#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    int res = sum_int_int(15, 27);
    printf("res = %d\n", res);
    exit(0);
}
