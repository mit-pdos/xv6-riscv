#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <wait.h>

#define BUF_SIZE 8192

int main(int argc, char* argv[]) {

    int pipefd[2];
    
    if (pipe(pipefd) < 0) {
        fprintf(stderr, "pipe error occured\n");
        exit(EXIT_FAILURE);
    }

    pid_t pid = fork();

    if (pid < 0) {
        fprintf(stderr, "fork error occured\n");
        close(pipefd[0]);
        close(pipefd[1]);
        exit(EXIT_FAILURE);
    }

    if (pid == 0) { // child

        close(pipefd[1]);

        char buffer[BUF_SIZE] = { 0 };
        ssize_t bytes_read;

        do {
            bytes_read = read(pipefd[0], buffer, sizeof(buffer));
    
            if (bytes_read < 0) {
                fprintf(stderr, "read error occured\n");
                close(pipefd[0]);
                exit(EXIT_FAILURE);
            }

            buffer[bytes_read] = '\0';
            printf("%s", buffer);

        } while (bytes_read);

        close(pipefd[0]);

        exit(EXIT_SUCCESS);
    }

    // parent

    close(pipefd[0]);

    for (int i = 1; i < argc; i++) {
        size_t len = strlen(argv[i]);
        size_t total_written = 0;

        while (total_written < len) {
            ssize_t bytes_written = write(
                pipefd[1],
                argv[i] + total_written,
                len - total_written
            );

            if (bytes_written < 0) {
                fprintf(stderr, "write error occured\n");
                close(pipefd[1]);
                exit(EXIT_FAILURE);
            }

            total_written += bytes_written;
        }

        char newline = '\n';
        ssize_t res = write(pipefd[1], &newline, 1);

        if (res <= 0) {
            fprintf(stderr, "write error occured\n");
            close(pipefd[1]);
            exit(EXIT_FAILURE);
        }
    }

    close(pipefd[1]);

    if (wait(NULL) < 0) {
        perror("wait");
        exit(EXIT_FAILURE);
    }

    exit(EXIT_SUCCESS);
}