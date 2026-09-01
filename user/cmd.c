#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int main(int argc,char *argv[])
{
    if(argc<2)
    {
        printf("Usage: cmd <command_to_execute> arguments\n");
        return 1;
    }
    int pid=fork();
    if(pid<0)
    {
        printf("failed to create a child process\n");
        return 1;
    }
    if(pid==0)
    {
        exec(argv[1],&argv[1]);
        printf("Command failed\n");
        exit(1);
    }
    int status=0;
    wait(&status);
    return status==0?0:1;
}