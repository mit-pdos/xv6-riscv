#include "kernel/types.h"
#include "user/user.h"

int custom_atoi(const char *str) {
    int result = 0;
    int sign = 1;

    // Check for negative sign
    if (*str == '-') {
        sign = -1;
        str++;
    }

    // Convert characters to integer
    while (*str >= '0' && *str <= '9') {
        result = result * 10 + (*str - '0');
        str++;
    }

    return sign * result;
}

int
main(int argc, char *argv[])
{
    int pid;

    char buffer[10];
    int n;

    printf("Enter a number to pass to child : ");

    n=read(0,buffer,sizeof(buffer));

    if(n<0)
    {
        printf("Error reading input\n");
        exit(0);
    }

    buffer[n-1]='\0';
    int arg=custom_atoi(buffer);
    pid = forkwitharg(arg);  // Pass test value 42
    if(pid < 0){
        printf("forkwitharg failed\n");
        exit(1);
    }
    
    if(pid == 0){
        // Child process
        printf("Child process created with argument: %d\n", getforkarg());
        printf("Child Pid : %u, Parent Pid : %lu\n",getpid(),getppid());
    } else {
        // Parent process
        wait(0);
        printf("In parent process\n");
        printf("Parent Pid : %u, Parent's Parent Pid : %lu\n",getpid(),getppid());
        // wait(0);
    }
    exit(0);
}