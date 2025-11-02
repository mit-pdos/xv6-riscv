#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"   // Este header define sleep(), fork(), exit(), wait(), etc.

int
main(int argc, char *argv[])
{
  int N = 10;
  for(int i = 0; i < N; i++){
    if(fork() == 0){
      int mytickets = 50 * (i + 1);
      settickets(mytickets);

      printf("Proceso hijo %d con %d tickets\n", getpid(), mytickets);

      for(;;) {
        volatile int x;
        for(x = 0; x < 10000000; x++);
      }

      exit(0);
    }
  }

  // Pausa principal para dejar que los hijos se ejecuten
  sleep(200);

  // Esperar que todos los hijos terminen
  for(int i = 0; i < N; i++)
    wait(0);

  exit(0);
}
