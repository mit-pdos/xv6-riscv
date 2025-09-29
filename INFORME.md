# Informe sobre la Implementación de las Llamadas al Sistema `getancestor` y `getppid` en xv6-riscv

## Funcionamiento de las Llamadas al Sistema

En xv6-riscv, las llamadas al sistema son la forma en que los programas de usuario interactúan de manera segura con el núcleo del SO. Aquí hemos implementado dos nuevas: `getancestor` y `getppid`, que ayudan a manejar info sobre el árbol de procesos.

-   **Cómo funciona `getancestor`**: Básicamente, deja que un proceso obtenga el PID de un ancestro en su árbol genealógico, indicando el nivel (0 para sí mismo, 1 para el padre, 2 para el abuelo, y así). Al llamar `getancestor(n)`, el núcleo sube por el árbol de procesos de forma recursiva, usando el campo `parent` de la estructura `proc`. Si el nivel existe, devuelve el PID; si no, tira -1.

-   **Cómo funciona `getppid`**: Es más simple, solo devuelve el PID del padre del proceso actual. Es como un atajo de `getancestor(1)`, yendo directo al campo `parent->pid` en la estructura del proceso. Si no hay padre (como en el proceso raíz), también devuelve -1.

-   **Cómo se integran**: Ambas se registran en la tabla de syscalls y se implementan en `sysproc.c` como `sys_getancestor` y `sys_getppid`. Los programas de prueba como `getancestor.c` y `test_getppid.c` muestran cómo usarlas en la práctica.

## Explicación de las Modificaciones Realizadas

El foco estuvo en extender xv6-riscv con estas dos nuevas syscalls. Los cambios clave fueron:

-   **En `kernel/syscall.h`**: Agregamos entradas nuevas en la tabla de syscalls, dándoles números únicos (SYS_getancestor y SYS_getppid) para que el sistema las reconozca.

-   **En `kernel/sysproc.c`**: Implementamos `sys_getancestor` y `sys_getppid`. La primera saca el argumento `n`, valida el nivel y recorre el árbol recursivamente. La segunda va directo al PID del padre, sin más rollo.

-   **En `user/user.h`**: Declaramos los prototipos de `getancestor` y `getppid` para que los programas de usuario puedan llamarlos.

-   **En `user/getancestor.c`**: Creamos un programa de prueba que llama a `getancestor` con valores como 0, 1, 2 y 10, imprimiendo los resultados para chequear que funcione bien, incluyendo errores.

-   **En `user/test_getppid.c`**: Otro programa de prueba para `getppid`, que simplemente obtiene e imprime el PID del padre, probando en distintos contextos.

Todo esto se hizo sin romper la compatibilidad con el resto del SO, siguiendo el estilo de las syscalls ya existentes en xv6.

## Dificultades Encontradas y Cómo se Resolvieron

No todo fue fácil, claro. Aquí van las principales piedras en el camino y cómo las sorteamos:

-   **Problema con el recorrido del árbol en `getancestor`**: Al principio, costaba acceder a ancestros lejanos por cómo están los punteros en `proc`. Lo arreglamos revisando la doc de xv6 y manejando bien los casos donde `parent` es NULL.

-   **Manejo de errores en niveles inválidos para `getancestor`**: Había que devolver -1 si `n` era mayor que la profundidad del árbol. Solución: agregar una verificación con un contador mientras se recorre.

-   **Implementación de `getppid`**: Parecía sencilla, pero había que cubrir el caso del proceso raíz. Lo hicimos chequeando si `parent` es NULL y devolviendo -1.

-   **Integración en la tabla de syscalls**: Surgieron conflictos con números repetidos para ambas. Arreglo: asignar números únicos libres en `syscall.h`.

-   **Compilación y pruebas**: Errores iniciales por dependencias faltantes. Lo resolvimos compilando poco a poco y probando con `getancestor.c` y `test_getppid.c`, asegurándonos de que los PIDs salieran bien en la consola.

En resumen, superamos todo consultando el código de xv6, probando paso a paso y aplicando buenas prácticas de desarrollo en SO.
