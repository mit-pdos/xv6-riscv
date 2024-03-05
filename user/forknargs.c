#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"



int main(int argc, char** argv) {
    //int p[2]; // [rd, wd]

    //int pid = fork();
    int a = argv[1][0];
    printf("%d", is_digit(a));
    exit(0);
}