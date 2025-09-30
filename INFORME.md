# T1 — Implementación de llamadas al sistema en xv6

## Ignacio Vidal y Felipe Céspedes - Grupo E

## 1. Objetivo
Implementar las funciones `getppid(void)` y `getancestor(int)`, las cuales utilizan llamadas a sistema para permitir que un proceso obtenga el PID de su padre o de un ancestro en la jerarquía de procesos. 

## 2. Funcionamiento de las llamadas a sistema
Las llamadas a sistema funcionan como un puente entre los programas en espacio de usuario y el kernel:

1. El programa en user space invoca una función (por ejemplo, `getppid`).
2. Se ejecuta un stub que carga el número de la syscall en un registro y realiza la instrucción `ecall`.
3. El kernel recibe la interrupción, consulta la tabla de syscalls y ejecuta la función `sys_*` correspondiente.
4. El resultado vuelve al programa de usuario.

## 3. Archivos modificados

### kernel/syscall.h  
Se definieron los números de syscall:  
#define SYS_getppid 22  
#define SYS_getancestor 23  
Estos números identifican las llamadas en el kernel.

### kernel/syscall.c  
Se declararon las funciones `sys_getppid` y `sys_getancestor`, y se agregaron a la tabla `syscalls[]`, que despacha cada número a la función del kernel correspondiente.

### kernel/sysproc.c  
Se implementaron las funciones del kernel:  
- `sys_getppid`: retorna el `pid` del proceso padre si existe, o -1 en caso contrario.  
- `sys_getancestor`: recibe un entero `n` y sube `n` veces en la cadena de padres, retornando el `pid` del ancestro encontrado o -1 si no existe.

### user/user.h  
Se añadieron los prototipos para que los programas de usuario puedan llamar directamente a `getppid()` y `getancestor(int)`.

### user/usys.pl  
Se agregaron las entradas:  
entry("getppid");  
entry("getancestor");  
Estas generan los stubs que ejecutan `ecall` con el número de syscall correcto.

### Makefile  
Se incluyó el nuevo programa de prueba `_yosoytupadre` en la variable `UPROGS`, para que el ejecutable quede disponible en la shell de xv6.

### user/yosoytupadre.c  
Se creó el programa de prueba que imprime el PID, el PPID y los ancestros del proceso, verificando los retornos de `getancestor()` y mostrando mensajes cuando un ancestro no existe.

## 4. Resultados de las pruebas
Al ejecutar `yosoytupadre` dentro de xv6 se observaron salidas como:

Soy 3, mi padre es 2  
Ancestro(0) = 3  
Ancestro(1) = 2  
Ancestro(2) = 1  
Ancestro(3): no hay bisabuelo  

En cada ejecución el PID cambia (4, 5, 6, …), pero la jerarquía se mantiene igual:  
- El proceso actual es hijo de `sh` (PID 2).  
- El abuelo siempre es `init` (PID 1).  
- No existe bisabuelo, por lo que `getancestor(3)` retorna **-1**, cumpliendo con lo solicitado en la tarea.


## 5. Dificultades encontradas
- Comprender la ruta completa de una syscall dentro de xv6. Se resolvió investigando el proceso a profundidad y revisando cómo estaba implementada `getpid`, para luego replicar su estructura.  
- Errores en el Makefile al incluir el nuevo programa, corregidos asegurando el uso correcto de `\` y formato LF.
- Entender como funciona la jerarquía de procesos y en que casos límite no existe un ancestro. Se resolvió a través de experimentar con la función creada.

## 6. Conclusión
La implementación permitió comprender mejor el flujo de una llamada a sistema, desde el espacio de usuario hasta el kernel, y la necesidad de coordinar múltiples archivos para que la comunicación funcione correctamente.
