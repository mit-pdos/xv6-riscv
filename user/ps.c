#include "kernel/types.h"
#include "user/user.h"
#include "kernel/param.h"
#include "kernel/spinlock.h"
#include "kernel/riscv.h"
#include "kernel/proc.h"

int main(int argc, char *argv[])
{
    getallprocs();

    return 0;
}
