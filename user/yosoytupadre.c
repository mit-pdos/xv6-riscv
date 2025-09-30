#include "kernel/types.h"
#include "user/user.h"


// YO.. SOY... TU PADRE!
// NOOOOO

int
main(void)
{
  int me = getpid();
  int p = getppid();
  printf("Soy %d, mi padre es %d\n", me, p);

  printf("Ancestro(0) = %d\n", getancestor(0)); // debería ser mi padre
  printf("Ancestro(1) = %d\n", getancestor(1)); // debería ser el abuelo
  printf("Ancestro(2) = %d\n", getancestor(2)); // debería ser el bisabuelo
 

  // (opcional) prueba con fork para ver relaciones:
  int pid = fork();
  if(pid == 0){
    // hijo
    printf("[Hijo] PID=%d, PPID=%d, abuelo=%d\n",
           getpid(), getppid(), getancestor(2));
    exit(0);
  } else {
    wait(0);
  }

  exit(0);
  
}