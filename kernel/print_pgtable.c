#include "param.h"
#include "types.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"
#include "proc.h"

int print_entry(pde_t entry, int ix, int level) {
    uint64 addr = PTE2PA(entry);
    while (--level > 0) printf("\t");
    printf("0x%x -> 0x%lx ", ix + 1, addr);
    const char FLAGS[] = "DAGUXWRV";
    const int FLAGS_CNT = 7;
    for (int f = FLAGS_CNT - 1; f >= 0; --f) {
        if (entry & (1L << f)) printf("%c", FLAGS[f]);
        else printf("_");
    }
    printf("\n");
    return 0;
}

uint64 sys_print_pgtable() {
    struct proc* myp = myproc();
    pagetable_t pgt = myp->pagetable;
    printf("PAGETABLE %lx\n", (uint64)pgt);
    for (int i = 0; i < 512; ++i) {
        pde_t entry = *(pgt + i);
        if (!(entry & PTE_V)) continue;
        uint64 addr = PTE2PA(entry);
        print_entry(entry, i, 1);
        pagetable_t pgt2 = (pagetable_t) addr;
        for (int j = 0; j < 512; ++j) {
            pde_t entry = *(pgt2 + j);
            if (!(entry & PTE_V)) continue;
            uint64 addr = PTE2PA(entry);
            print_entry(entry, j, 2);
            pagetable_t pgt3 = (pagetable_t) addr;
            for (int k = 0; k < 512; ++k) {
                pde_t entry = *(pgt3 + k);
                if (!(entry & PTE_V)) continue;
                print_entry(entry, k, 3);
            }
        }
    }
    return 0;
}