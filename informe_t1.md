# INFORME_T1 
## 1. Cambios realizados

### Syscalls
- **getppid():** retorna el PID del proceso padre del proceso actual.
- **getancestor(n):** retorna el PID del ancestro `n` del proceso actual (`n=0` → proceso actual, `n=1` → padre, `n=2` → abuelo, etc.). Si no existe, retorna `-1`.

### Archivos modificados / añadidos
- `kernel/syscall.h`: agregado `#define SYS_getppid` y `#define SYS_getancestor`.
- `kernel/syscall.c`: mapeo en la tabla `syscalls[]`:
  - `[SYS_getppid] = sys_getppid`
  - `[SYS_getancestor] = sys_getancestor`
- `kernel/sysproc.c`: implementación de:
  ```c
  extern struct proc *myproc(void);

  uint64
  sys_getppid(void) {
    struct proc *p = myproc();
    if(p->parent) return p->parent->pid;
    return -1;
  }

  uint64
  sys_getancestor(void) {
    int n;
    argint(0, &n);              // lee el parámetro n
    if(n < 0) return -1;
    struct proc *p = myproc();
    for(int i = 0; i < n; i++) {
      if(p->parent == 0) return -1;
      p = p->parent;
    }
    return p->pid;
  }
 Userland:
user/user.h: prototipos int getppid(void); int getancestor(int);
user/usys.pl: agregadas entradas getppid y getancestor.
user/test_syscalls.c: programa de prueba simple para ambas syscalls.
user/yosoytupadre.c: programa que acepta n (por defecto 2) e imprime PID, PPID y ancestro n.

Makefile:
Incluidos los binarios en UPROGS: $U/_test_syscalls\
$U/_yosoytupadre\  Problemas encontrados y soluciones:
Error “commands commence before first target” en Makefile: causado por líneas en blanco o espacios/tabs fuera de las reglas. Se eliminó el salto de línea extraño entre UPROGS y la regla siguiente.
Errores argint y paréntesis: al inicio se usó if(argint(0, &n) < 0), luego se cambió a separar la lectura del argumento (argint(0, &n);) y las validaciones (if(n < 0) return -1;) para claridad.
Orden y limpieza del mapeo de syscalls en kernel/syscall.c para mantener coherencia con xv6.


