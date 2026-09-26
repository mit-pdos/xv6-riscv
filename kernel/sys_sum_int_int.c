#include "types.h"
#include "riscv.h"
#include "defs.h"

uint64
sys_sum_int_int(void)
{
    int a, b;
    argint(0, &a);
    argint(1, &b);

    printk("Суммирование\n");

    return a + b;
}
