#include "kernel/types.h"
#include "user/user.h"

typedef struct task_t {
    int x;
    int y;
    char op; // '+', '-', '*', '/'
    int result;
    int error;
} task_t;

int calc(int x, int y, char op, int *result) {
    *result = 0;
    switch (op) {
        case '+': *result = x + y; return 0;
        case '-': *result = x - y; return 0;
        case '*': *result = x * y; return 0;
        case '/':
            if (y == 0) return -1;
            *result = x / y; return 0;
        default: return -1;
    }
}

void server(int read_fd, int write_fd) {
    task_t t;
    while (read(read_fd, &t, sizeof(t)) > 0) {
        t.error = calc(t.x, t.y, t.op, &t.result);
        if (t.error) {
            printf("Calc failed: error code %d\n", t.error); 
        }
        write(write_fd, &t, sizeof(t));
    }
    exit(0);
}

void client(int write_fd, int read_fd, task_t t) {
    write(write_fd, &t, sizeof(t));
    read(read_fd, &t, sizeof(t));
    printf("Result: (%d ", t.x);
    write(1, &t.op, 1);
    printf(" %d) = %d, error: %d\n", t.y, t.result, t.error);
    exit(0);
}

int main() {
    int pipe1[2], pipe2[2];
    pipe(pipe1); 
    pipe(pipe2); 

    task_t task = {10, 4, '-', 0, 0};

    if (fork() == 0) {
        close(pipe1[0]);
        close(pipe2[1]);
        client(pipe1[1], pipe2[0], task);
    }

    close(pipe1[1]);
    close(pipe2[0]);
    server(pipe1[0], pipe2[1]);
    wait(0);
    exit(0);
}
