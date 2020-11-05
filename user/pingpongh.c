// pingpong.c for xv6 (assignment #1 for CSC.T371)
// name: Yusuke Uchida
// id: 18B02210

#include <assert.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

// <<<remove this comment and fill your code here if needed>>>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stdout, "usage: %s N\n", argv[0]);
        exit(1);
    }

    // # of rounds
    int n = atoi(argv[1]);

    // tick value before starting rounds
    int start_time = time(NULL);

    int fd1[2];  // parent to child: fd1
    int fd2[2];  // child to parent: fd2
    int pid, status;

    pipe(fd1);
    pipe(fd2);
    pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(errno);
    } else if (pid == 0) {  // child
        unsigned char count;
        close(fd1[1]);
        close(fd2[0]);
        for (int i = 0; i < n; i++) {
            status = read(fd1[0], &count, 8);
            if (status == -1) {
                exit(-1);
            }
            count += 1;
            // printf("%d\n", (int)count);
            status = write(fd2[1], &count, 8);
            if (status == -1) {
                exit(-1);
            }
        }
        exit(0);
    } else {  // parent
        unsigned char count = 0;
        close(fd1[0]);
        close(fd2[1]);
        for (int j = 0; j < n; j++) {
            status = write(fd1[1], &count, 8);
            if (status == -1) {
                exit(-1);
            }
            status = read(fd2[0], &count, 8);
            if (status == -1) {
                exit(-1);
            }
            count += 1;
            // printf("%d\n", (int)count);
        }
        wait(&status);
    }

    // print # of ticks in nrounds
    printf("# of ticks in %d rounds: %ld\n", n, time(NULL) - start_time);
    exit(0);
}
