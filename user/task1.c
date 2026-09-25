#include "kernel/types.h"
#include "user/user.h"

#define TICKS_PER_SECOND 10

int main(int argc, char* argv[]){
    int pid;
    int result;
    int status;

    if (argc != 2 || (argv[1][0] != 'a' && argv[1][0] != 'b')){
        printf("Wrong import\n");
        exit(1);
    }

    pid = fork();

    if (pid < 0){
        printf("Fork failed\n");
        exit(1);
    }

    if (pid == 0){
        int seconds = 5;
        pause(TICKS_PER_SECOND * seconds);
        exit(1);
    }

    printf("parentid = %d, childid = %d\n", getpid(), pid);

    if (argv[1][0] == 'b'){
        if (kill(pid) < 0){
            exit(1);
        }
    }

    result = wait(&status);

    printf("childid = %d, exitcode = %d\n" , result, status);

    exit(0);

}