#include "kernel/types.h"
#include "user/user.h"
#include "kernel/param.h"
#include "kernel/spinlock.h"
#include "kernel/riscv.h"
#include "kernel/proc.h"

int main(int argc, char *argv[])
{
    // list all running processes
    // struct proc *procs = getallprocs();
    getallprocs();
    // printf("[DEBUG] mz3lts\n");
    //  for (int i = 0; i < NPROC; i++)
    //{
    //      // printf("[DEBUG] Process %d\n", p->pid);
    //      if (procs[i].state == 4)
    //      {
    //          printf("[DEBUG] Process %d found.\n", procs[i].pid);
    //      }
    //  }
}
