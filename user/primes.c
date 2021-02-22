#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUF_SIZE 40

int main(int argc, char *argv[]){

        if(argc >= 2){
                fprintf(2, "Error: Too many argument for command primes...\n");
        }

        int p[2];
        pipe(p);

        for(int i = 2;i < 36;i++){
                write(p[1], &i, sizeof(int));
        }
        
        int ctn = 1; /* ctn stand for continue */
        while(ctn){
                int pid = fork();
                int prime;
                int value;

                if(pid == 0){
                        int buffer[BUF_SIZE];
                        int size = 0;
                        
                        close(p[1]);
                        read(p[0], &prime, sizeof(int));
                        printf("prime %d\n", prime);
                        for(;;){
                                if(read(p[0], &value, sizeof(int)) == 0) break;
                                                        
                                /* 
                                 * Buffer temporily store the pipe of current
                                 * and previous process.
                                */
                                if(value % prime != 0){
                                        buffer[size++] = value;
                                }
                        }
                        close(p[0]);
                        
                        if(size == 0) ctn = 0;
                        
                        pipe(p);
                        
                        /* For pipe of current and next process */
                        for(int i = 0;i < size; i++){
                                write(p[1], &buffer[i], sizeof(int));
                        }
                        
                }
                else{
                        close(p[1]);
                        close(p[0]);
                        wait(0);
                        ctn = 0;
                }
        }
        
        exit(0);
}
