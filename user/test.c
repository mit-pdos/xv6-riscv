#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int 
main(int argc, char* argv[])
{
    int a = 2;
    int b = 3;

    if (argc == 3) {
        a = atoi(argv[1]);
        b = atoi(argv[2]);
    }

    int result = sum(a, b);
    printf("результат сложения равен %d\n", result); 

    return(0);
}

