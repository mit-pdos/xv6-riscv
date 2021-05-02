#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"


void
main(int argc, char *argv[])
{

    fprintf(2, "strating usertests!\n");
    int pid = fork();
    if(pid==0){
        fprintf(2, "Im the child\n");
        // int start = uptime();
        // int end = uptime();
        // int counter = 0;
        // while (end-start < 1000){
        //     counter++;

        //     if (end-start % 100 ==0){
        //         fprintf(2, "tick: %d\n",end-start);
        //     }
        //     end = uptime();        
        // }
        // int counter =1;
        // int flip =0;
        //  while(1){
        //      flip = ~flip;
        //      counter++;
        //      if((counter % 5000)==0){
        //          fprintf(2, "child:%d\n", counter);
        //      }
        //  }
    }
    else{
        // for (int i=0; i<10000; i++){
            
        // }
        fprintf(2,"SIGSTOP response:%d\n",kill(pid,SIGSTOP));
      
        fprintf(2,"SIGCONT response:%d\n",kill(pid,SIGCONT));
        wait(&pid);
        fprintf(2,"I'm the parent\n");
    }
    exit(0);

}