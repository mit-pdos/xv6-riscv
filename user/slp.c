#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

#define IOCOUNT 50

int main()
{
    printf("Executing iochild!\n");
    for(int i = 1; i <=10; i++)
    {   int count = 0;
        int pid = fork();
        if(pid > 0){
            printf("I'm the parent doing  CPU bound task: my child=%d.  \n", pid);

            while(count < 10){
                for(int i =1; i<1000000000; i++){

                }
                count +=1;

            }

            printf("cpu task done \n");
            pid = wait((int *) 0);
            printf("I'm the parent. I see my child with pid %d has exited\n", pid);
        } else if(pid == 0){
            printf("iochild forking another child\n");
            int cpid = fork();
            int count = 0;
            if(cpid > 0)
            {
                printf("I'm child 1: my child = %d\n", cpid);
                pid = wait((int *) 0);
                printf("I'm child 1. I see my child with pid %d is done with I/O and exited\n", cpid);
                printf("Now I'm going to sleep for a while!\n");
                while(count < 10){
                    for(int i =1; i<1000000000; i++){

                    }
                    count +=1;

                }
                exit(0);
            }
            else if(cpid == 0)
            {
                printf("I'm child 2: Going to do a heavy file I/O operation\n");
                int count =0;
                while(count < 10){
                    for(int i =1; i<1000000000; i++){

                    }
                    count +=1;

                }

                exit(0);
            }
        } else {
            printf("fork error\n");
        }
    }
    exit(0);
}
