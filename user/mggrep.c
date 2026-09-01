#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int main (int argc,char *argv[])
{
    if(argc<3)
    {
        printf("Usage mggrep <pattern> <file1> <file2> ... <fileN>\n");
        return 0;
    }
    char *pattern=argv[2];
    int pid=0;
    for(int i=3;i<argc;i++)
    {
        pid=fork();
        if(pid<0)
        {
            printf("fork failed\n");
            continue;
        }
        if(pid==0)
        {
            int fd=open(argv[i],O_RDONLY);
            if(fd<0)
            {
              printf("Failed to open %s file by worker : %d\n",argv[1],pid);
              exit(1);
            }
        }
    }
    while(1)
    {
        int pid=wait(0);
        if(pid<-1)
         break;
    }
    return 1;
}