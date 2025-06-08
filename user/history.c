#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
int 
main(void)
{
    //Assignment 2 - Program to print out the contents of sh_history.
    int fd = open("sh_history", O_RDONLY);
    if(fd<0){
        exit(1);
    }
    char buf[128];
    int n;
    while((n=read(fd, buf,sizeof(buf)))>0){
        for(int i = 0; i<n; i++){
            write(1, &buf[i],1);
        }
    }
    close(fd);
    exit(0);
}