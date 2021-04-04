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
        while (c < 99)
        {
            printf("%d\n", c);
            c++;
        }
        printf("\n");
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

    sleep(1);
    sbrk(4096);

    exit(0);
}



// #################################### runner ##########################


int
main(void)
{
  
  int res = test();
  printf("test1 res: %d\n", res);

  return 0;
}
