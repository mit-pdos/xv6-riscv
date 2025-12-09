#include "kernel/types.h"
#include "user/user.h"

int
main()
{
    char *addr = sbrk(4096); // Reservar una página
    addr[0] = 'X';

    printf("Antes de proteger: %c\n", addr[0]);

    if (mrdprotect(addr, 1) < 0) {
        printf("mrdprotect falló\n");
        exit(1);
    }

    printf("Protegido contra lectura. Voy a intentar leer...\n");

    // Esto DEBE causar un fallo (page fault)
    char c = addr[0];

    // Si llega aquí, es un error
    printf("Leí: %c (NO debería pasar)\n", c);

    if (munrdprotect(addr, 1) < 0) {
        printf("munrdprotect falló\n");
        exit(1);
    }

    printf("Protección revertida.\n");
    exit(0);
}
