#include "types.h"
#include "riscv.h"
#include "defs.h"

int sys_add(int a, int b) {
    argint(0, &a);
    argint(1, &b);

    return a + b;
}