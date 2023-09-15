#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
    int i;
    char *args[MAXARG];
    if (argc < 3 || argv[1][0]<'0' || argv[1][0]>'9'){ //if the mask number is not a num -> error
        fprintf(2,"incorrect arguments for command %s",argv[0]);//2 is from stat.h
        exit(1);
    }

    if (trace(atoi(argv[1])) < 0){
        fprintf(2,"system call trace failed to retrieve the number from user mode");
        exit(1);
    }

    for (i=2;i<argc && i-2 < MAXARG;i++){
        args[i-2] = argv[i];
    }
    exec(args[0],args);
    exit(0);
}