#include "kernel/types.h"
#include "user/user.h"


// YO.. SOY... TU PADRE!


/*
 * Programa de prueba: yosoytupadre
 *
 * Objetivo:
 *   Verificar el funcionamiento de las nuevas llamadas al sistema
 *   getppid() y getancestor(n).
 *
 * Descripción:
 *   - Imprime el PID del proceso actual y el PID de su padre.
 *   - Llama a getancestor(n) para n = 0, 1, 2 y 3.
 *   - Muestra el PID del ancestro correspondiente si existe.
 *   - Si el ancestro no existe, imprime un mensaje explicativo.
 *
 * Casos esperados en xv6:
 *   - Ancestro(0) = PID del proceso actual.
 *   - Ancestro(1) = PID del padre (normalmente el shell, PID=2).
 *   - Ancestro(2) = PID del abuelo (normalmente init, PID=1).
 *   - Ancestro(3) = -1 (no existe bisabuelo en xv6).
 */

int
main(void)
{
  // PID actual y padre inmediato
  int me = getpid();
  int p = getppid();
  printf("Soy %d, mi padre es %d\n", me, p);

  // Ancestro nivel 0: el propio proceso
  int a0 = getancestor(0);
  if(a0 == -1)
    printf("Ancestro(0): no existe este proceso\n");
  else
    printf("Ancestro(0) = %d\n", a0);

  // Ancestro nivel 1: el padre
  int a1 = getancestor(1);
  if(a1 == -1)
    printf("Ancestro(1): no hay padre\n");
  else
    printf("Ancestro(1) = %d\n", a1);

  // Ancestro nivel 2: el abuelo
  int a2 = getancestor(2);
  if(a2 == -1)
    printf("Ancestro(2): no hay abuelo\n");
  else
    printf("Ancestro(2) = %d\n", a2);

  // Ancestro nivel 3: el bisabuelo (no debería existir en xv6)
  int a3 = getancestor(3);
  if(a3 == -1)
    printf("Ancestro(3): no hay bisabuelo\n");
  else
    printf("Ancestro(3) = %d\n", a3);

  // Finaliza el programa
  exit(0);
}
