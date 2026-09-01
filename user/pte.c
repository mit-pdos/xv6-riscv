#include "kernel/types.h"
#include "user/user.h"

/*
 * This program tests whether a virtual address has
 * a valid page table entry in the current process.
 */

int main(int argc, char *argv[])
{
       int local_var = 10;

       uint64 mapped_va = (uint64)&local_var; // A known mapped user virtual address
       uint64 unmapped_va = 0x100000000ULL;   // Some random address that has not been used yet

       printf("VA: %p valid: %d\n",
              (void *)mapped_va,
              pte_valid(mapped_va));

       printf("VA: %p valid: %d\n",
              (void *)unmapped_va,
              pte_valid(unmapped_va));

       exit(0);
}
