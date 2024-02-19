#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"

uint64 sys_add(void)
{
    int num1;
    argint(0, &num1);
    int num2;
    argint(1, &num2);

    return num1 + num2;

  return 0;
}