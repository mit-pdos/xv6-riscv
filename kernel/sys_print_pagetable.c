#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void
print_pt(pagetable_t current_pagetable, int dots)
{

  for (int i = 0; i < 512; i++) {
    pte_t pte = current_pagetable[i];
    if (!(pte & PTE_V)) {
      continue;
    }

    char flags[] = {(pte & PTE_R) ? 'R' : '_', (pte & PTE_W) ? 'W' : '_',
                    (pte & PTE_X) ? 'X' : '_', (pte & PTE_U) ? 'U' : '_',
                    (pte & PTE_G) ? 'U' : 'G', (pte & PTE_A) ? 'A' : '_',
                    (pte & PTE_D) ? 'D' : '_', '\0'};

    if (dots == 1) {
      printk("..........");
    }

    if (dots == 2) {
      printk("....................");
    }
    printk("0x%x - %p - %s\n", i, (void *)PTE2PA(pte), flags);

    // дочерняя таблица:
    if (!(pte & (PTE_X | PTE_R | PTE_W)))
      print_pt((pagetable_t)(PTE2PA(pte)), dots + 1);
  }
}

uint64
sys_print_pagetable()
{
  struct proc *current_proccess = myproc();
  pagetable_t current_pagetable = current_proccess->pagetable;
  printk("PAGETABLE: %p\n", (void *)current_pagetable);
  print_pt(current_pagetable, 0);
  return 0;
}
