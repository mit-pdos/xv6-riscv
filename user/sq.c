#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    printf("square of 2 is %d\n", square(2));
    printf("square of 5 is %d\n", square(5));
    exit(0);
}
