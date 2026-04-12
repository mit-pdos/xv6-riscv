#include "param.h"
#include "types.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"
#include "proc.h"

#define TABLE_DEPTH 3
#define TABLE_SIZE 512

int print_entry(pde_t entry, int ix, int level) {
    uint64 addr = PTE2PA(entry);
    while (--level > 0) printf("\t");
    printf("0x%x -> 0x%lx ", ix + 1, addr);
    const char FLAGS[] = "VRWXUGAD";
    const int FLAGS_CNT = 8;
    for (int f = 1; f < FLAGS_CNT; ++f) {
        if (entry & (1L << f)) printf("%c", FLAGS[f]);
        else printf("_");
    }
    printf("\n");
    return 0;
}

void print_table(int level, pagetable_t pgt) {
    for (int i = 0; i < TABLE_SIZE; ++i) {
        pde_t entry = *(pgt + i);
        if (!(entry & PTE_V)) continue;
        print_entry(entry, i, level);
        if (level < TABLE_DEPTH) {
            uint64 addr = PTE2PA(entry);
            pagetable_t pgt2 = (pagetable_t) addr;
            print_table(level + 1, pgt2);
        }
    }
}

uint64 sys_print_pgtable() {
    struct proc* myp = myproc();
    pagetable_t pgt = myp->pagetable;
    printf("PAGETABLE %lx\n", (uint64)pgt);
    print_table(1, pgt);
    return 0;
}

uint64 sys_remove_flags() {
    struct proc* myp = myproc();
    uint64 bufVa = myp->trapframe->a0;
    uint64 bufLen = myp->trapframe->a1;
    uint64 mask = myp->trapframe->a2;
    const uint64 PTE_AD = PTE_A | PTE_D;
    if (((mask | PTE_AD) ^ PTE_AD) != 0)
        return -1;

    pagetable_t pgt = myp->pagetable;

    uint64 pageVa = PGROUNDDOWN(bufVa);
    for (; pageVa < bufVa + bufLen; pageVa += PGSIZE) {
        pte_t *pte;
        if (pageVa >= MAXVA)
            return -1;
        pte = walk(pgt, pageVa, 0);
        if (pte == 0)
            return -1;
        if ((*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
            return -1;
        *pte |= mask;
        *pte ^= mask;
    }
    return 0;
}