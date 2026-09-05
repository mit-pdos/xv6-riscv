#include "stdio.h"
#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_sum(void)
{
    int a = 0;
    int b = 0;

    argint(0, &a);
    argint(1, &b);

    int result = a + b;

    printk("sys_sum: результат=%d\n", result);
    
    return result;
}

