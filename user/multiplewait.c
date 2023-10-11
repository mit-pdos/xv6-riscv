#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    printf("Parent %d will start %d processes\n", getpid(), atoi(argv[1]));

    for (int i = 1; i <= atoi(argv[1]); i++)
    {
        int rc = fork();
        if (rc < 0 )
        {
            fprintf(2, "Fork failed!\n");
            exit(1);
        } else if (rc == 0)
        {
            printf("Hello I'am child %d!\n", i);
        } else 
        {
            int status;
            wait(&status);
            printf("Child %d finished with status %d!\n", i, status);  
            exit(0);  
        }
    }

    exit(0);
}