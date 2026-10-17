#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main (int argc, char* argv[]) {
    if (argc != 3) {
        printf("Error: wrong arguments count");
        exit(1);
    }

    else {
        int a = atoi(argv[1]);
        int b = atoi(argv[2]);

        int res = add(a, b);
        printf("%d", res);

        exit(0);
    }
}
