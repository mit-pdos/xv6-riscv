// Assignment 1
//Write a user program exectime.c to present the real time (also called clock time) spent on 
// executing a shell command. Print the start time and completion time in terms of the ticks. 
// • It should be executed within xv6. 
// • In xv6, only Makefile can be changed. 
// • It is ok if the output contains some other information. 
// • Not required to handle composite shell commands like ls | wc -w (composed of two basic 
// shell commands via pipe). 
// • The number of command line arguments for exectime should not be fixed. 
 
// Use xv6 system calls: uptime, fork, exec, wait. Pay attention to their syntax (could be different 
// from Unix). 


#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[]) {
    int pid;
    int status;
    int start_time, end_time;

        
    start_time   = uptime();
    printf("uptime: %d \n",start_time);            
    pid = fork();
    if (pid == 0) {
        exec(argv[1], &argv[1]);
        exit(1);
    } else if (pid < 0) {
        printf("fork failed\n");
        exit(1);
    } else {
        wait(&status);
        end_time = uptime();
        printf("uptime: %d\n",end_time);
    }

    
    exit(0);
}

