#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    int pipefd[2];

    if (pipe(pipefd) < 0){
        exit(1);
    }

    int pid = fork();

    if (pid < 0){
        exit(1);
    }

    if (pid == 0){
        close(pipefd[1]);
        close(0);             
        if (dup(pipefd[0]) < 0){  
            exit(1);
        }
        close(pipefd[0]);           
        char *argv_wc[] = {"/wc", 0};
        exec("/wc", argv_wc);
        exit(1);

    } else {
        close(pipefd[0]);
        for (int i = 1; i < argc; i++){
            int len = strlen(argv[i]);
            int written = 0;
            while (written < len) {
                int n = write(pipefd[1], argv[i] + written, len - written);
                if (n < 0) {
                    exit(1);
                }
                written += n;
            }
            if (write(pipefd[1], "\n", 1) != 1){
                exit(1);
            }
        }

        close(pipefd[1]);
        wait(0);
        exit(0);
    }
}