#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int child_proc() {
    sleep(100);
    exit(1);
}

int main(int argc, char **argv) { // a) part - -a flag, b) part - -b flag
    if (argc != 2) {
        write(2, "Only 1 argument needed.\n", 23);
        exit(1);
    }

    int pid = fork();
    if (pid < 0) {
        write(2, "Fork error.\n", 12);
        exit(1);
    }

    if (0 == pid) child_proc();
    printf("===== STARTED =====\nParentID: %d, ChildID: %d\n", getpid(), pid);

    if (!strcmp("-a", argv[1])) {
        // just waiting
    } else if (!strcmp("-b", argv[1])) {
        int kill_stat = kill(pid);
        if (kill_stat < 0) {
            write(2, "THIS CHILD IS IMMORTAL!!!", 25);
            exit(1);
        }
    } else {
        write(2, "Invalid arguments.\n", 23);
        exit(1);
    }

    int status, ended_pid = wait(&status);
    printf("\n===== ENDED =====\nEnded process ID: %d, Ended process status: %d\n", ended_pid, status);

    exit(0);
};