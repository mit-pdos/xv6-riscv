#include <stddef.h>
#include "kernel/types.h"
#include "user/user.h"
// #include <assert.h>

int
main(int argc, char *argv[])
{

int pipe1[2];
int pipe2[2];
int pid;
char byte = 0xFF;
int exchanges = 0;

if(pipe(pipe1) < 0 || pipe(pipe2) < 0){
    exit(1);
}

pid = fork();
if(pid<0){
    exit(0);
}

if(pid==0){
    if(read(pipe1[0], &byte, 1) !=1){
        exit(1);
    }
    exchanges++;
    if(write(pipe2[1], &byte, 1)!= 1){
        exit(1);
    }
}
else{
    close(pipe1[0]); //Close read end of pipe1
    close(pipe2[1]); //close write end of pipe2
    
    int elapsed = 0;

    while(elapsed < 5){
        if(write(pipe1[1], &byte, 1) != 1){
            exit(1);
        }
        if(read(pipe2[0], &byte, 1) != 1){
            exit(1);
        }
        exchanges++;
        if(exchanges % 100 == 0){
            sleep(1);
            elapsed++;
        }
    }
    float exchanges_persecond = exchanges/5.0;
    printf("Total exchanges: %d\n", exchanges);
    printf("Exchanges per second: %.2f\n", exchanges_persecond);    
    close(pipe1[1]);
    close(pipe2[0]);
    kill(pid);
    exit(0);
    }
}
