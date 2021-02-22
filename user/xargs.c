#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int stdin_arg(char **argv, int offset){
        char ch, *p;
        int done = 1;
        
        *argv[offset] = '\0';
        
        p = argv[offset];
        while(done){
            done = read(0, &ch, 1);
            if(ch == '"'){
                    continue;
            }
            else if (ch == '\\'){
                read(0, &ch, 1);
                *p = '\0';
                break;
            }
            else if(ch == '\n'){
                *p = '\0';
                break;
            }
            else{
                *p++ = ch; 
            }
        }
        
        return (done == 1)? 1:0;
}

int main(int argc, char *argv[]){
        char cmd[100];
        int i, arg_off = 1;
        
        if(strcmp(argv[1], "-n") == 0) arg_off = 3;

        strcpy(cmd, argv[arg_off]);
        
        for(i = 1;i < argc - arg_off;i++){
                strcpy(argv[i], argv[i + arg_off]);
        }
        
        arg_off = i;
        for(i = arg_off + 1;i < argc;){
                argv[i++] = 0;
        }
        
        int done = 1;
        while(done){
                done = stdin_arg(argv, arg_off);
                if(*argv[arg_off] != '\0'){
                    if(fork() == 0){
                        exec(cmd, argv);
                    }
                    else{
                        wait(0);
                    }
                }
        }  
 
       exit(0);
}
