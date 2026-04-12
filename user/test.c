#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"

void print_va(uint64 va){
    printf("\nix1: 0x%lx \nix2: 0x%lx \nix3: 0x%lx \nshift: %ld\n", PX(2, va) + 1, PX(1, va) + 1, PX(0, va) + 1, va & (PGSIZE - 1));
}

int main() {
    print_pgtable();

    printf("\ncreate an array in stack\n");
    [[maybe_unused]] int stackBuf[100];
    print_va((uint64) stackBuf);
    printf("\n");
    print_pgtable();

    printf("\ncreate an array in heap ");
    const int heapBufSz = 10000;
    [[maybe_unused]] int* bigBuf = malloc(heapBufSz * sizeof(int));
    print_va((uint64) bigBuf);
    printf("\n");
    for (int i = 0; i < heapBufSz; ++i){
        bigBuf[i] = 123;
    }
    print_pgtable();
    printf("\nremove flags from heap buffer\n");
    if (remove_flags((uint64)bigBuf, sizeof(int) * heapBufSz, PTE_A|PTE_D) < 0){
        printf("failed to remove flags\n");
        return 1;
    }
    if (remove_flags((uint64)stackBuf, sizeof(stackBuf), PTE_D) < 0){
        printf("failed to remove flags\n");
        return 1;
    }
    print_pgtable();
    
    return 0;
}