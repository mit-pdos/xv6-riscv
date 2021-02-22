#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
    int p[2]; /* 0 for read, 1 for write */
    char key_byte = '\0';

    if(argc >= 2) fprintf(2, "Error: Too many argument for command pingpong...\n");

    if(pipe(p) < 0) printf("building pipe failed!\n");

    if(fork() == 0){
            while(key_byte != 'p') read(p[0], &key_byte, sizeof(char));
            key_byte = 'c'; /* c stand for child */
            printf("%d: received ping\n", getpid());
            write(p[1], &key_byte, sizeof(char));
            close(p[0]);
            close(p[1]);
    }
    else{
            key_byte = 'p'; /* p stand for parent */
            write(p[1], &key_byte, sizeof(char));
            wait(0);
            read(p[0], &key_byte, sizeof(char));
            printf("%d: received pong\n", getpid());
            close(p[0]);
            close(p[1]);
    }
    exit(0);
}
