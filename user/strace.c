#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[])
{

    int valid_number = (argc>=3);
    if (!valid_number || atoi(argv[1])<0 ) {
        fprintf(2, "Usage: strace <mask> <command>");
        exit(1);
    }

    int mask = atoi(argv[1]);
    if(trace(mask) < 0){
        fprintf(2, "trace failed\n");
        exit(1);
    }

    char *args[argc-2];
    for (int i = 2; i < argc; i++)
    {
        args[i-2] = argv[i];
    }
    args[argc-2] = 0;
    exec(args[0], args);
    exit(0);

}
        
         

