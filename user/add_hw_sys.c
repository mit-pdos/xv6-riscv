#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    if (argc != 3) exit(1);

    int a = atoi(argv[1]);
    int b = atoi(argv[2]);

    int sum = add(a, b);

    printf("%d\n", sum);
    exit(0);
}
