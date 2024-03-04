#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define FORK_ERR_LEN       24
#define KILL_ERR_LEN       32
#define MANY_ARGS_ERR_LEN  41
#define UNKWN_ARGS_ERR_LEN 40

int
main(int argc, char* argv[]) {
    if (argc > 2) {
        write (2, "Error: too many command line arguments!\n", MANY_ARGS_ERR_LEN);
        exit(1);
    }

    int pid = fork();     // pid = process id
    if (pid < 0) {        // error 
        write(2, "Error: failed to fork!\n", FORK_ERR_LEN);
        exit(1); 
    }

    if (pid == 0) {      // child process 
        sleep(100);      // sleeping for 10 seconds
	    exit(1);
    }
    else {               // parent process    
        printf("Parent process id: %d\nChild process id: %d\n", getpid(), pid);
        int status, cpid;

        if (!strcmp(argv[1], "-a") || argc == 1) {
            cpid = wait(&status);
            printf("Process %d exited with status %d\n", cpid, status);     
        }
        else if (!strcmp(argv[1], "-b")) {
            int kill_rslt = kill(pid);
            if (kill_rslt < 0) {
                write(2, "Error: failed to kill process!\n", KILL_ERR_LEN);
                exit(1);
            }
            else {
                cpid = wait(&status);
                printf("Process %d exited with status %d\n", cpid, status);
            }       
        }
        else {
            write (2, "Error: unknown command line arguments!\n", UNKWN_ARGS_ERR_LEN);
            exit(1);           
        }
    }

    exit(0);
}