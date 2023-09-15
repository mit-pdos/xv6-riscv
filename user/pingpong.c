#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>


int main(int argc,char * argv[]){
    int fd1[2];
    int fd2[2], pid;

    if (pipe(fd1) == -1 || pipe(fd2) == -1){
        return 1;
    }

    pid = fork();
    if (pid < 0){
        return 1;
    }

    if (pid != 0){ //it is a the parent process
        char  read_from_child[] = "x";
        write(fd1[1],"a",1);
        close(fd1[1]);

        //wait(NULL);//wait for the child process to complete

        read(fd2[0],read_from_child,1);
        if(*read_from_child == 'b'){
            printf("pid = %d ",pid);
            printf("pong\n");
        }
        exit(0);
    }

    else{
        char read_from_parent[] = "x";
        read(fd1[0],read_from_parent,1);
        if(*read_from_parent == 'a'){
            printf("pid = %d ",pid);
            printf("ping\n");
        }

        write(fd2[1],"b",1);
        close(fd2[1]);
        exit(0);
    }

    exit(0);

}