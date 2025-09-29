#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    printf("Ancestro 0 (yo): %d\n", getancestor(0));
    printf("Ancestro 1 (padre): %d\n", getancestor(1));
    printf("Ancestro 2 (abuelo): %d\n", getancestor(2));
    printf("Ancestro 10 (demasiado): %d\n", getancestor(10));
    exit(0);
}