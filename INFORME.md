# INFORME T1 - Ignacio Millar (https://github.com/elmillarx/xv6-riscv/tree/ignacio_millar_t1)

## Funcionamiento de las llamadas al sistema

* Las llamadas al sistema (syscalls) permiten que los programas de usuario accedan a servicios del kernel.
En xv6, cada syscall se define  en user.h, se le asigna un numero unico en syscall.h, se conecta en la tabla de syscalls en syscall.c, y se implementa en el kernel (por ejemplo, en sysproc.c).

## Modificaciones realizadas
### Punto de partida: getpid()
Se tomo como referencia la syscall getpid() mediante busqueda en VSCode y donde aparecia se fue agregando siguiendo su logica

1. **user.h**
   * Vemos donde esta getpid() y se agrega:
     int getppid(void);
     int getancestor(int);

2. **syscall.h**
   * Encontramos el numero de getpid y definimos las nuevas llamadas agregandoles un numero
     #define SYS_getppid     22
     #define SYS_getancestor 23
     
3. **syscall.c**
   * Se agrego:
     extern uint64 sys_getppid(void);
     extern uint64 sys_getancestor(void);

     [SYS_getppid]     sys_getppid,
     [SYS_getancestor] sys_getancestor,

4. **sysproc.c**
   * Se encontro aqui la funcion sys_getpid() y su funcionamiento, y a partir de esta se se hizo la logica para las nuevas llamadas

5. **usys.pl**
   * Esto hara que se genere usys.S para las llamadas
     entry("getppid");
     entry("getancestor");
     
## Programa de prueba (yosoytupadre.c)
   * Se creo el programa en user que entrega getppid() y para getancestor() el cual para este pide un numero N e imprime todos los ancestros desde 0 hasta N deteniendose si retorna -1

## Dificultades encontradas
* Donde agregar el codigo: Al inicio no estaba claro, pero buscando getpid() en VSCode y replicando su donde se encontraba se fueron agregando los llamados. Fue necesario modificar varios archivos en conjunto (user.h, syscall.h, syscall.c, sysproc.c).
* Uso de argint: Genero error porque no retorna valor y no entendia porque no aceptaba el argumento. Y con la ayuda de gpt la forma correcta era con argint(0, &n);.
* Entrada en xv6: Como no funcionaba scanf, tuve que ver que este no existe en xv6 y se uso un read + atoi para leer N en el programa de prueba
* Otro problema fue entender el Makefile y donde agregar yosoytupadre.c y al ver el pdf que mencionaba que iba en user al buscar este en el Makefile y agregarlo en ese apartado funcino