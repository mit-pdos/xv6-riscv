# overall
本文讲述sleep进程添加流程

# code
sleep用户代码较为简单，贴出来即可
```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(2, "Usage: %s <num> \n", argv[0]);
        exit(1);
    }
    if (sleep(atoi(argv[1])) < 0)
        fprintf(2, "Sleep error\n");

    printf("sleep %d end\n", atoi(argv[1]));
    exit(0);
}
```

**技术点在于如何添加系统调用**

1. 在usys.pl中添加sleep系统调用，在编译时会生成对应的系统调用代码

    ```asm
    sleep:
        li a7, SYS_sleep
        ecall
        ret
    ```
    这里要了解一个riscv知识点，a7寄存器保存系统调用编号，ecall陷入系统调用时会去执行这个sys call，ecall结束后ret返回至用户代码

2. 添加SYS_sleep必要的代码

    ```c
    // syscall.c
    static uint64 (*syscalls[])(void) = {
        ......
        [SYS_sleep] sys_sleep,
    };
    extern uint64 sys_sleep(void);

    //syscall.h
    #define SYS_sleep  22

    // sysproc.c
    uint64 sys_sleep(void)
    {
        int n;
        uint ticks0;

        argint(0, &n);
        acquire(&tickslock);
        ticks0 = ticks;
        while (ticks - ticks0 < n) {
            if (myproc()->killed) {
                release(&tickslock);
                return -1;
            }
            sleep(&ticks, &tickslock);
        }
        release(&tickslock);
        return 0;
    }
    ```
    值得注意的时sys_sleep的编写

