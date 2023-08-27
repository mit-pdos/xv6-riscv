#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#define READ  0
#define WRITE 1
#define stderr 2

//注释1： 为什么在SieveErato中第一个从pipe中取出的数字一定是个素数？
//根据质因数分解定理：每个合数都可以由至少一个素数来分解。 既每个合数都由至少一个比其小的素数组成
//因此如果此时从pipe中取出的数字不是素数，他会在注释2已经被之前的素数filter掉了.

//注释2：filter掉当前素数的倍数(即可以被当前素数整除)

int SieveErato(int left[2]){
    int pid, prime, temp_num, right[2];
    close(left[WRITE]);
    if (read(left[READ],&prime,sizeof(int)) == 0){  //注释1
        close(left[READ]);
        exit(0);
    }

    printf("prime %d\n",prime);

    if (pipe(right) == -1){
    return 1;
    }

    if((pid = fork()) < 0){
        fprintf(stderr, "fork error...\n");
        close(right[READ]);
        close(right[WRITE]);
        close(left[READ]);
        exit(1);
    }

    if(pid > 0 ){ //parent process
        close(right[READ]);
        while (read(left[READ],&temp_num,sizeof(int)) !=0){
            if (temp_num % prime == 0) continue; //get filtered  #注释2
            write(right[WRITE],&temp_num,sizeof(int));
        }
        close(right[WRITE]);
        wait(0);
        exit(0);
    }

    else{
        SieveErato(right);
        exit(0);
    }


}


int main(int agrc, char *agrv[]){
    int pid,i,left[2];

    if (pipe(left) == -1){
    return 1;
    }

    if((pid = fork()) < 0){
        fprintf(stderr, "fork error...\n");
        close(left[READ]);
        close(left[WRITE]);
        exit(1);
    }

    if (pid > 0){ //parent process
        close(left[READ]);
        for(i=2; i<=35; i++){
            //printf("the current i is: %d\n",i)
            write(left[WRITE],&i,sizeof(int));
        }
        close(left[WRITE]); //This is a must otherwise, the read will be blocked forever.
        wait(0); //wait for the child to finish before exits
        exit(0);
    } 

    else { //the child process
        SieveErato(left);
        exit(0);
    }

}