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
    printf("%d: pte %p pa %p | V: %d R: %d W: %d E: %d A: %d\n", pte_index, pte, pa, (pte & PTE_V) > 0, 
                (pte & PTE_R) > 0, (pte & PTE_W) > 0, (pte & PTE_X) > 0,(pte & PTE_A) > 0); 
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