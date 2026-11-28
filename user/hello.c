#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int main(int argc, char* argv[]) {
    if (argc != 2) {
        exit(1);
    }

    int fork_status = fork();
    int parrent_pid;
    if (fork_status < 0) {
        exit(1);
    }
    else if (fork_status == 0) {
        pause(100);
        exit(1);
    }
    else {
        if (*argv[1] == 'a') {
            parrent_pid = getpid();
            
            printf("%d %d\n", parrent_pid, fork_status);

            int status;
            int child_pid = wait(&status);
            
            printf("%d %d\n", child_pid, status);

            exit(0);
        }
        else if (*argv[1] == 'b') {
            kill(fork_status);

            int status = 0;
            int child_pid = wait(&status);

            printf("%d %d\n", child_pid, status);

            exit(0);
        }
        else {
            printf("Wrong arguments\n");
            exit(1);
        }
    }
}
    