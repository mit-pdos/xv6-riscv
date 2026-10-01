#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("not enough arguments\n");
        exit(1);
    }

    int pipefd[2];
    if (pipe(pipefd) != 0) {
        printf("pipe failed\n");
        exit(1);
    }

    int pid = fork();
    if (pid < 0) {
        printf("fork failed\n");
        exit(1);
    }
    else if (pid == 0) {
        if (close(0) != 0) {
            printf("stdin close failed\n");
            exit(1);
        }
        if (dup(pipefd[0]) != 0) {
            printf("dup failed\n");
            exit(1);
        }
        if (close(pipefd[0]) != 0) {
            printf("pipe read close failed\n");
            exit(1);
        }

        if (close(pipefd[1]) != 0) {
            printf("pipe write close failed\n");
            exit(1);
        }

        char *wc_argv[] = {"/wc", 0};
        exec("/wc", wc_argv);

        printf("exec /wc failed\n");
        exit(1);
    }

    if (close(pipefd[0]) != 0) {
        printf("pipe read close failed\n");
        if (close(pipefd[1]) != 0) {
            printf("pipe write close failed\n");
        }
        if (wait(0) < 0) {
            printf("wait failed\n");
        }
        exit(1);
    }

    for (int i = 1; i < argc; ++i) {
        int len = strlen(argv[i]);
        if (write(pipefd[1], argv[i], len) != len ||
            write(pipefd[1], "\n", 1) != 1) {
                printf("write failed\n");
                if (close(pipefd[1]) != 0) {
                    printf("pipe write close failed\n");
                }
                if (wait(0) < 0) {
                    printf("wait failed\n");
                }
                exit(1);
        }
    }

    if (close(pipefd[1]) != 0) {
        printf("pipe write close failed\n");
        if (wait(0) < 0) {
            printf("wait failed\n");
        }
        exit(1);
    }

    if (wait(0) < 0) {
        printf("wait failed\n");
        exit(1);
    }

    exit(0);
}
