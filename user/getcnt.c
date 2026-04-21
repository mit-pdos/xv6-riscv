#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    if(argc != 2){
        fprintf(2, "uso: getcnt <syscall_id>\n");
        exit(1);
    }
    int id = atoi(argv[1]);
    int count = getcnt(id);
    if(count < 0){
        fprintf(2, "getcnt: syscall id invalido: %d\n", id);
        exit(1);
    }
    printf("syscall %d has been called %d times\n", id, count);
    exit(0);
}