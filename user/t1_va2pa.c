#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    char *p1;
    char *p2;

    // Allocate first page
    p1 = sbrk(4096);

    // Allocate second page
    p2 = sbrk(4096);

    printf("VA1: 0x%lx -> PA1: 0x%lx\n",
           (uint64)p1, va2pa((uint64)p1));

    printf("VA2: 0x%lx -> PA2: 0x%lx\n",
           (uint64)p2, va2pa((uint64)p2));

    exit(0);
}