#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"

void print_va(uint64 va){
    printf("ix1: 0x%lx \nix2: 0x%lx \nix3: 0x%lx \nshift: %ld\n", PX(2, va) + 1, PX(1, va) + 1, PX(0, va) + 1, va & (PGSIZE - 1));
}
int globalVar = 0;
int main() {
    print_pgtable();

    printf("\nglobal var:\n");
    print_va((uint64)&globalVar);
    
    [[maybe_unused]] int stackVar = 0;
    printf("\nstack var:\n");
    print_va((uint64) &stackVar);

    printf("\narray in stack:\n");
    [[maybe_unused]] int stackBuf[100];
    print_va((uint64) stackBuf);
    
    printf("\narray in heap:\n");
    const int heapBufSz = 10000;
    [[maybe_unused]] int* bigBuf = malloc(heapBufSz * sizeof(int));
    print_va((uint64) bigBuf);

    printf("\n");
    print_pgtable();

    printf("\nremove all A and D flags\n\n");
    if (remove_flags((uint64)bigBuf, sizeof(int) * heapBufSz, PTE_A|PTE_D) < 0){
        printf("failed to remove flags\n");
        return 1;
    }
    if (remove_flags((uint64)stackBuf, sizeof(stackBuf), PTE_A|PTE_D) < 0){
        printf("failed to remove flags\n");
        return 1;
    }
    if (remove_flags((uint64)(&globalVar), sizeof(globalVar), PTE_A|PTE_D) < 0){
        printf("failed to remove flags\n");
        return 1;
    }
    if (remove_flags((uint64)(&stackVar), sizeof(stackVar), PTE_A|PTE_D) < 0){
        printf("failed to remove flags\n");
        return 1;
    }
    print_pgtable();

    if (check_flags((uint64)bigBuf, sizeof(int) * heapBufSz, PTE_A|PTE_D) != 0) {
        printf("test check empty flags failed\n");
        return 1;
    }
    bigBuf[0] = bigBuf[1024];
    stackVar = globalVar;
    printf("\npage table after data access\n");
    print_pgtable();

    if (check_flags((uint64)bigBuf, 1LL, PTE_A) != 1 || check_flags((uint64)bigBuf, 1LL, PTE_D) != 1){
        printf("test1 check flags failed\n");
        return 1;
    }
    if (check_flags((uint64)bigBuf + 4096, 1LL, PTE_A) != 1){
        printf("test2 check flags failed\n");
        return 1;
    }
    if (check_flags((uint64)bigBuf + 4096, 1LL, PTE_D) != 0){
        printf("test3 check flags failed\n");
        return 1;
    }
    if (check_flags((uint64)stackBuf, 1LL, PTE_A) != 1 || check_flags((uint64)stackBuf, 1LL, PTE_D) != 1){
        printf("test4 check flags failed\n");
        return 1;
    }
    if (check_flags((uint64)&globalVar, 1LL, PTE_A) != 1 || check_flags((uint64)&globalVar, 1LL, PTE_D) != 0){
        printf("test5 check flags failed\n");
        return 1;
    }
    
    free(bigBuf);
    printf("\npagetable after free\n");
    print_pgtable();
    return 0;
}