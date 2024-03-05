#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "lab2_checkers.c"

const int BUFF_SIZE = 10;

void child_proc(int *p) {
    close(p[1]); // Будем только читать
    close(0);
    dup(p[0]);
    close(p[0]);

    char *argv[] = {"/wc", 0};
    exec("/wc", argv);

    // Если мы дошли до этого фрагмента кода, значит exec упал
    raise_err("Exec error occurred: can't exec '/wc'.\n");
}

int main(int argc, char **argv) {
    int p[2]; // [rd, wd]
    pipe(p);

    int pid = fork();
    fork_check(pid);

    if (pid == 0) {
        child_proc(p);
    }

    close(p[0]); // Будем только писать
    char arg_buff[BUFF_SIZE];
    int arg_len;
    for (int i = 1; i < argc; i++) {
        arg_len = strlen(argv[i]);

        if (arg_len >= BUFF_SIZE) { // Завершаемся, как джентльмены
            close(p[1]);
            wait((int *) 0);
            raise_err("Buffer overflow.\n");
        }

        strcpy(arg_buff, argv[i]);
        arg_buff[arg_len] = '\n';
        write(p[1], arg_buff, arg_len + 1);
    }

    close(p[1]);
    wait((int *) 0);
    exit(0);
}