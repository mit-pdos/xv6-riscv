#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[]) {
    int pid = getpid();
    printf("--------------\n");
    printf("ID del proceso: %d\n", pid);
    printf("\n");

    // T1 Parte I
    printf("Parte I\n");
    int ppid = getppid();
    printf("getppid() - ID del proceso padre: %d\n", ppid);
    printf("\n");
    
    // T1 Parte II getancestor
    printf("Parte II\n"); 
    printf("Ingrese el numero de ancestros a consultar: ");
    int N;
    char buf[16]; // en xv6 no hay scanf asi que usamos read
    int n = read(0, buf, sizeof(buf));  // lee desde stdin
    printf("\n");
    if (n <= 0) {
        printf("Error al leer entrada\n");
        exit(1);
    }
    buf[n] = 0;   // terminador de string
    N = atoi(buf);
    for (int i = 0; i <= N; i++) {
        int pid = getancestor(i);
        if (pid == -1) {
            printf("getancestor(%d) no existen mas ancestros del proceso: %d\n", i, pid);
            break;
        } else {
            printf("getancestor(%d)- ID del proceso: %d\n", i, pid);
        }
    }
    exit(0);
}