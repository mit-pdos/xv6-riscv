#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
        
        if(argc < 2){
                fprintf(2, "Usage: sleep for seconds...\n");
                exit(1);
        }
        
        if(checkint(argv[1])){
                fprintf(2, "Error: argument not available...\n");
                exit(1);
        }
        
        sleep(atoi(argv[1]));
        exit(0);
}
