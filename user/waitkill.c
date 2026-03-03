#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {

    if (argc != 2)
        goto wrong_format;

    int is_wait = strcmp(argv[1], "wait") == 0;
    int is_kill = strcmp(argv[1], "kill") == 0;

    if (!is_wait && !is_kill)
        goto wrong_format;

    int pid = fork();

    if (pid < 0) {
        fprintf(2, "fork failed\n");
        exit(1);
    }

    if (pid == 0) { //child
        pause(100); // 1 tick ~ 1/10 seconds
        exit(1);
    }

    // parent code

    printf("Our pid: %d\n", getpid());
    printf("Child pid: %d\n", pid);

    if (is_kill) {
        if (kill(pid) < 0) {
            fprintf(2, "kill of process %d failed\n", pid);
            exit(1);
        }
    }

    int waited_exit_code;
    int waited_pid = wait(&waited_exit_code);

    if (waited_pid < 0) {
        fprintf(2, "wait failed\n");
        exit(1);
    }

    printf("Waited process id: %d\n", waited_pid);
    printf("Waited procces exit code: %d\n", waited_exit_code);

    exit(0);

wrong_format:
    fprintf(2, "wrong format: expected 'waitkill [wait|kill]'\n");
    exit(1);
}
