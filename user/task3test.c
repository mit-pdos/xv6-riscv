#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"


// #################################### TESTS ##########################

int
test(){
printf("started\n");

    int pid2;
    if ((pid2 = fork()) == 0)
    {
        int c = 0;
        while (c < 3)
        {
            printf("sooonnn");
            sleep(10);
            c++;
        }
        while (c < 1000)
        {
            printf("%d\n", c);
            c++;
        }
        printf("\n");
        exit(0);
    }
    else
    {
        int status;
        struct perf p;

        int x = wait_stat(&status, &p);

        printf("ret val: %d ", x);
        printf("ctime: %d ", p.ctime);
        printf("ttime: %d ", p.ttime);
        printf("stime: %d ", p.stime);
        printf("retime: %d ", p.retime);
        printf("rutime: %d\n", p.rutime);
        printf("xstate: %d\n\n", status);

    }

    wait(0);
    sleep(1);
    sbrk(4096);

    return 0;
}   

int
priorityTest(){
    int mask = (1 << SYS_priority);

    int pid = fork();
    trace(mask, pid);
    if(pid == 0){
        int badRes = priority(7);
        if(badRes == 0){
            printf("boundries not working");
            return -1;
        }

        for(int i = 1; i < 6; i++){
            int goodRes = priority(i);
            if(goodRes != 0){
                printf("priority set not working");
                return -1;
            }
        }
        exit(0);
    }
    wait(0);
    return 0;
}

int fcfsTest(){
    
    sleep(10);

    // create son
    int pid = fork();
    // int father = getpid();
    // int mask1 = (1 << SYS_sbrk);
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if(pid == 0){
        for (int i = 0; i < 1000;i++)
            printf("pid: %d ,my turn now\n", pid);
        exit(0);
    }
    // father
    else{
        for (int i = 0; i < 1000; i++)
            printf("father before son!\n");
    }

    struct perf p;

    int x = wait_stat(0,&p);
    printf("ret val: %d ", x);
    printf("ctime: %d ", p.ctime);
    printf("ttime: %d ", p.ttime);
    printf("stime: %d ", p.stime);
    printf("retime: %d ", p.retime);
    printf("rutime: %d\n", p.rutime);

    return 0;
}

// ############################### TASK 4 Test #############################



// #################################### runner ##########################


int
main(void)
{
  
  int res = test();
  printf("test1 res: %d\n", res);

  printf("\n############################### TASK 4 Test #############################\n\n");
  int res1 = priorityTest();
  printf("test2 res: %d\n\n\n", res1);

  int res2 = fcfsTest();
  printf("fcfs test res: %d\n\n\n", res2);

  exit(0);
  return 0;
}
