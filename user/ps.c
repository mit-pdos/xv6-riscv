#include "kernel/types.h"
#include "kernel/param.h"
#include "kernel/pstat.h"
#include "user/user.h"


int main(){
    struct pstat ps;
    if(getpinfo(&ps) < 0){
        printf("getpinfo failed\n");
        exit(1);
    }
    printf("PID PPID STATE SIZE     NAME\n");
    for(int i = 0; i < NPROC; i++){
        if(ps.pid[i] > 0){ //if we have an active process
            printf("%d  %d  %d  %ld  %s\n",
                ps.pid[i],ps.ppid[i],ps.state[i],ps.size[i],ps.name[i]);

        }
    }
    exit(0);
}