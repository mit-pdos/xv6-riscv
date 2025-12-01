# Informe de Implementación

## Tarea 3 -- Protección de Lectura en XV6

### Introducción

El objetivo de esta tarea fue extender el sistema operativo XV6 para
incorporar un mecanismo de protección de memoria que permita
deshabilitar la lectura de una o más páginas de un proceso, manteniendo
al mismo tiempo el permiso de escritura. Este tipo de protección es útil
para escenarios donde se requiere almacenar información sensible que
debe poder modificarse, pero no ser leída, como claves criptográficas o
datos temporales de seguridad.

Para lograr esto, se implementaron dos nuevas llamadas al sistema:

-   `mrdprotect(void *addr, int len)`\
    Quita el permiso de lectura en un rango de páginas.

-   `munrdprotect(void *addr, int len)`\
    Restaura el permiso de lectura en ese rango.

A continuación se describe cada archivo modificado, qué se hizo, dónde y
por qué.



## Archivos Modificados y Cambios Realizados

### 1. `kernel/vm.c`

Se agregó al final del archivo la implementación completa de las
funciones:

-   `int mrdprotect(void *addr, int len);`
-   `int munrdprotect(void *addr, int len);`

Estas funciones recorren las páginas del proceso correspondiente y
modifican directamente los bits del Page Table Entry (PTE),
específicamente el bit PTE_R, encargado de habilitar la lectura.

Los cambios realizados permiten:

-   En `mrdprotect`: limpiar el bit PTE_R para deshabilitar lectura.
-   En `munrdprotect`: restaurar el bit PTE_R para habilitar lectura
    nuevamente.

Ambas funciones validan dirección, alineación, pertenencia a espacio de
usuario y existencia del PTE.



### 2. `kernel/defs.h`

Se agregaron las declaraciones:

    int mrdprotect(void *addr, int len);
    int munrdprotect(void *addr, int len);

Esto permite que otros archivos del kernel, como `sysproc.c`, puedan
llamar a las funciones implementadas en `vm.c`.


### 3. `kernel/syscall.h`

Se añadieron los números de syscall:

    #define SYS_mrdprotect 22
    #define SYS_munrdprotect 23

Estos identificadores permiten registrar y mapear correctamente las
nuevas llamadas al sistema.


### 4. `kernel/syscall.c`

Cambios realizados:

-   Se agregaron las declaraciones externas:

```{=html}
<!-- -->
```
    extern uint64 sys_mrdprotect(void);
    extern uint64 sys_munrdprotect(void);

-   Se incorporaron las nuevas syscalls en la tabla `syscalls[]`:

```{=html}
<!-- -->
```
    [SYS_mrdprotect] sys_mrdprotect,
    [SYS_munrdprotect] sys_munrdprotect,

Esto habilita que el número de syscall invoque a su manejador
correspondiente.


### 5. `kernel/sysproc.c`

Se implementaron los wrappers:

    uint64 sys_mrdprotect(void) { ... }
    uint64 sys_munrdprotect(void) { ... }

Su función es recibir parámetros desde espacio de usuario (dirección y
cantidad de páginas), validarlos y llamar a las funciones reales
definidas en `vm.c`.


### 6. `user/usys.pl`

Se añadieron las entradas necesarias para generar automáticamente los
stubs de usuario:

    entry("mrdprotect");
    entry("munrdprotect");

Esto genera en tiempo de compilación los archivos necesarios para
invocar las syscalls desde programas de usuario.


### 7. `user/user.h`

Se agregaron los prototipos para uso en user space:

    int mrdprotect(void *addr, int len);
    int munrdprotect(void *addr, int len);

Sin estos prototipos, los programas de usuario no podrían llamar
correctamente a las nuevas funciones.


### 8. `user/rdprotect_test.c`

Se incorporó el programa oficial de prueba, cuyo propósito es validar el
correcto funcionamiento del mecanismo. El programa:

1.  Reserva una página de memoria.
2.  Escribe en ella.
3.  Llama a `mrdprotect` para deshabilitar lectura.
4.  Verifica que aún se puede escribir.
5.  Intenta leer, lo cual debe generar un page fault.
6.  Restaura la lectura con `munrdprotect`.

Este test confirma que la protección y la restauración funcionan
correctamente.


### 9. `Makefile`

Se agregó el programa `_rdprotect_test` a la variable `UPROGS` para que
sea compilado y esté disponible como binario de usuario.


## Resultado Final

Con todas las modificaciones implementadas:

-   Las nuevas llamadas al sistema funcionan correctamente.
-   Se logra deshabilitar la lectura en páginas específicas del espacio
    de usuario.
-   Es posible seguir escribiendo en memoria protegida.
-   La lectura de una página marcada como no legible provoca el page
    fault esperado.
-   El mecanismo `munrdprotect` revierte correctamente la protección.

Este trabajo añade a XV6 una funcionalidad de protección de memoria que
no forma parte del sistema original, cumpliendo con los objetivos de la
tarea.
