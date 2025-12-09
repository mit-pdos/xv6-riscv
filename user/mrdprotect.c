#include "kernel/types.h"
#include "user/user.h"

int main() {
    char *x = sbrk(4096);
    x[0] = 'X';

    printf("Antes de proteger: %c\n", x[0]);
    mrdprotect(x, 1);

    printf("Protegido contra lectura. Voy a intentar leer...\n");
    printf("%c\n", x[0]);   // Debe generar trap

    munrdprotect(x, 1);
    printf("Después de desproteger: %c\n", x[0]);
    exit(0);
}
