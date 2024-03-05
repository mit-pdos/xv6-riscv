#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/lab2_checkers.c"

void child_proc() {
    sleep(100);
    exit(1);
}

int main(int argc, char **argv) { // a) part - -a flag, b) part - -b flag
    if (argc != 2) {
        raise_err("Only 1 argument needed.\n");
    }

    int pid = fork();
    fork_check(pid);

    if (0 == pid) {
        child_proc();
    }
    printf("===== STARTED =====\nParentID: %d, ChildID: %d\n", getpid(), pid);

    if (!strcmp("-a", argv[1])) {
        // just waiting
    } else if (!strcmp("-b", argv[1])) {
        int kill_status = kill(pid);
        kill_check(kill_status);
    } else {
        raise_err("Invalid arguments.\n");
    }

    int status, ended_pid = wait(&status);
    printf("\n===== ENDED =====\nEnded process ID: %d, Ended process status: %d\n", ended_pid, status);

    exit(0);
};