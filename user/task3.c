#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int p[2];
    
    if (argc < 2) {
        printf("No arguments\n");
        exit(1);
    }

    pipe(p);
    int pid = fork();

    if (pid > 0) {
        close(p[0]); 

        for (int i = 1; i < argc; i++) {
            write(p[1], argv[i], strlen(argv[i]));
            if (i < argc - 1) {
                write(p[1], " ", 1);
            }
        }
        
        write(p[1], "\n", 1);

        close(p[1]); 
        
        wait((int *) 0);
        
        exit(0); 

    } else if (pid == 0) {
        close(0);
        dup(p[0]);
        
        close(p[0]);
        close(p[1]);

        char *new_argv[] = { "/wc", 0 };
        
        exec("/wc", new_argv);
        
        printf("exec failed!\n");
        exit(1);
    } else {
        printf("fork failed\n");
        exit(1);
    }
}
