#include "types.h"
#include "riscv.h"
#include "defs.h"

uint64 sys_add(int a, int b) {
    argint(0, &a);
    argint(1, &b);

    printf("%d\n", a + b);
    return 0;
}