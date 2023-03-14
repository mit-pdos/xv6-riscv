#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#define BUF_SIZE 32

char buf[BUF_SIZE];
int p[2];

int receive(int id) {
    char c;
    int length = 0;
    while (1) {
        read(id, &c, 1);
        if (c == '\n')
            break;
        if (length + 1 < BUF_SIZE)
            buf[length++] = c;
    }
    buf[length++] = '\n';
    return length;
}

int main() {
    char* argv[2];
    argv[0] = "wc";
    argv[1] = 0;

    pipe(p);
    int pid = fork();
    if (pid > 0) {
        close(p[0]);
        int length = receive(0);
        write(p[1], buf, length);
        close(p[1]);
        wait((int *) 0);
    } else if (pid == 0) {
        close(0);
        dup(p[0]);
        close(p[0]);
        close(p[1]);
        exec("/wc", argv);
    }

    return 0;
}
