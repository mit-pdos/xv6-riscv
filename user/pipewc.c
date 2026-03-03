#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {

    int pipefd[2];
    
    if (pipe(pipefd) < 0) {
        fprintf(2, "pipe failed\n");
        exit(1);
    }
    
    int pid = fork();

    if (pid < 0) {
        fprintf(2, "fork failed\n");
        close(pipefd[0]);
        close(pipefd[1]);
        exit(1);
    }

    if (pid == 0) { // child 
        close(pipefd[1]); // closed writing

        close(0); // closed stdin
        
        if (dup(pipefd[0]) < 0) {
            fprintf(2, "dup failed\n");
            close(pipefd[0]);
            exit(1);
        }

        close(pipefd[0]);

        char *wc_args[] = { "/wc", 0 };
        exec("/wc", wc_args);

        fprintf(2, "exec failed\n");
        exit(1);
    }

    // parent

    close(pipefd[0]); // closed reading

    for (int i = 1; i < argc; i++) {
        char *arg = argv[i];
        int len = strlen(arg);
                
        if (write(pipefd[1], arg, len) != len) {
            fprintf(2, "write failed\n");
            close(pipefd[1]);
            exit(1);
        }

        if (write(pipefd[1], "\n", 1) != 1) {
            fprintf(2, "write failed\n");
            close(pipefd[1]);
            exit(1);
        }
    }

    close(pipefd[1]); // closed writing

    int status;
    if (wait(&status) < 0) {
        fprintf(2, "wait failed\n");
        exit(1);
    }

    exit(0);
}
