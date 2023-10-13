#include "param.h"
#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"

#define NUM_PTES  512// the number of page-table entries in each page-table page

void print_pagetable(pagetable_t pagetable, int level) {
  for (int pte_index = 0; pte_index < NUM_PTES; ++pte_index) {
    pte_t pte = pagetable[pte_index];
    if (!(pte & PTE_V))
      continue; // pte is not valid
    for (int i = 0; i < level; ++i)
      printf(" ..");
    uint64 pa = PTE2PA(pte); // physical address of the page    
    printf("%d: pte %p pa %p\n", pte_index, pte, pa);
    if ((pte & (PTE_R | PTE_W | PTE_X)))
      continue; // this is final level of the tree
    print_pagetable((pagetable_t)pa, level + 1);
  }
}

uint64 sys_vmprint() {
  pagetable_t pagetable = myproc()->pagetable;
  printf("page table %p\n", pagetable);
  print_pagetable(pagetable, 1);
  return 0;
}