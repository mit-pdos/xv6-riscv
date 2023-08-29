#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"

#define stdin  0
#define stdout 1
#define stderr 2


int main(int argc, char*argv[]){
    int i, ret, pid, arg_idx = 0;
    char *args[MAXARG];
    char arg[1024], buf; //the argument from sdin

    if (argc < 2) {
        fprintf(stderr,"missing arguments");
        exit(1);
    }
    
    for (i=1;i < argc;i++) args[i-1] = argv[i]; //copy everything from argv to args excluding the xargs command
    args[argc - 1] = arg;
    args[argc] = 0; //null character

    while ((ret = read(stdin,&buf,1)) > 0){
        if (!(buf == ' ' || buf == '\n')) {
            arg[arg_idx] = buf;
            arg_idx ++;
        }
        
        else{
            arg[arg_idx] = 0; //null character to mark end of the string
            
            if((pid = fork()) < 0){
                fprintf(stderr, "fork error...\n");
                exit(1);
            }
            if(pid == 0) exec(args[0],args);
            
            else{ //parent process
                wait(0);
                arg_idx = 0;   
            }
        }
    }

    if (ret < 0) {
        fprintf(stderr, "read error...\n");
        exit(1);
    }
    exit(0);
}
