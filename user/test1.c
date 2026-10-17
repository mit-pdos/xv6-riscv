#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {

    if (argc == 2) {
        int fork_status = fork();
    
        if (fork_status < 0) {
            printf("fork error\n");
            exit(1);
        }

        else if (fork_status == 0) {
            pause(100);        
            exit(1);
        }

        else {
            int parent_pid = getpid();
            printf("Parent ID: %d", parent_pid);
            
            if (argv[1][0] == 'a') {
            int status;
            int child_pid = wait(&status);

            printf("Child ID: %d", fork_status);
            printf("Child status: %d", child_pid);

            exit(0);
            }
            
            else if (argv[1][0] == 'b') {
                kill(fork_status);

                int status = 0;
                int child_pid = wait(&status);

                printf("Child ID: %d", fork_status);
                printf("Child status: %d", child_pid);

                exit(0);
            }
            
            else {
                printf("Wrong argument");
                exit(1);
            }
        }
    }

    else {
        printf("Wrong argumnets count");
        exit(1);
    }
}
