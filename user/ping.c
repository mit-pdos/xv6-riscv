#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    int p[2];
    int q[2];
    pipe(p);
    pipe(q);

    int ld;
    if (initlk(&ld)) {
        printf("err: No lock available in pool\n");
        exit(1);
    }

    int pid = fork();
    if (pid == 0) {

        close(p[1]);
        close(q[0]);
        
        char buf;
        while (read(p[0], &buf, 1)) {
            acqlk(ld);
            printf("%d: received %c\n", getpid(), buf);
            write(q[1], &buf, 1);
            rellk(ld);
        }

        close(p[0]);
        close(q[1]);
    } else {
        close(p[0]);
        close(q[1]);

        write(p[1], argv[1], strlen(argv[1]));
        close(p[1]);

        char buf;
        while (read(q[0], &buf, 1)) {
            acqlk(ld);
            printf("%d: received %c\n", getpid(), buf);
            rellk(ld);
        }

        wait(0);
        close(q[0]);
    }

    return 0;
}
