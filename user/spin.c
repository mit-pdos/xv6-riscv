#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]){
    int n = 100;
    if(argc > 1){
        n = atoi(argv[1]);
    }
    printf("spinning for %d ticks (pid %d)\n",n,getpid());
    pause(n);
    printf("spin done (pid %d)\n",getpid());
    exit(0);
}