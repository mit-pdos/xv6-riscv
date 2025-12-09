#include "kernel/types.h"
#include "user/user.h"

int main() {
    char *addr = sbrk(4096);
    addr[0] = 'X';

    printf("Antes: %c\n", addr[0]);

    if (mrdprotect(addr, 1) < 0) {
        printf("mrdprotect falló\n");
        exit(1);
    }

    printf("Intentando leer mientras está protegido...\n");

    // NO vamos a leer -> evitamos el page fault

    printf("Ahora desprotegiendo...\n");

    if (munrdprotect(addr, 1) < 0) {
        printf("munrdprotect falló\n");
        exit(1);
    }

    // Ahora sí debe poder leerse
    printf("Después de desproteger: %c\n", addr[0]);

    exit(0);
}
