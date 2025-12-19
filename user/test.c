#include "user/user.h"
#include "../uproc.h"
int
main(void)
{
    int pid1, pid2;

    // Fork program1
    if((pid1 = fork()) == 0){
        // Child: run program1
        exec("program1", (char*[]){ "program1", 0 });
        exit(0);
    }

    // Fork program2
    if((pid2 = fork()) == 0){
        // Child: run program2
        exec("program2", (char*[]){ "program2", 0 });
        exit(0);
    }

    // Parent: set nice values
    setnice(pid1, 5);   // program1 gets nice = 5 (less priority)
    setnice(pid2, -5);  // program2 gets nice = -5 (higher priority)

    // Wait for both children
    wait(0);
    wait(0);

    // After both finish, run ps to see vruntime
    int n;
    struct uproc procs[16];  // adjust max if needed
    n = getprocs(procs, 16);

    printf("PID\tNICE\tSTATE\tVRUNTIME\tNAME\n");
    for(int i = 0; i < n; i++){
        printf("%d\t%d\t%d\t%lu\t%s\n",
            procs[i].pid,
            procs[i].nice,
            procs[i].state,
            procs[i].vruntime,
            procs[i].name);
    }

    exit(0);
}
