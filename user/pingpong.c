#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int p1[2], p2[2];
    pipe(p1); // parent to child
    pipe(p2); // child to parent

    char* buffer[1];

    if(fork() == 0)
    {
        close(p1[1]);
        read(p1[0], buffer, 1);
        close(p1[0]);
        printf("PID: %d, Ping ontvangen!\n", getpid());  

        close(p2[0]);
        write(p2[1], "Byte", 1);
        close(p2[1]);      
    }else
    {
        close(p1[0]);
        write(p1[1], "Byte", 1);
        close(p1[1]);

        close(p2[1]);
        read(p2[0], buffer, 1);
        close(p2[0]);
        printf("PID: %d, Pong ontvangen!\n", getpid());
    }
    exit(0);
}