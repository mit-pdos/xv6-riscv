#include "param.h"
#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"

#define MAX_BYTES_FOR_CHECKING 512
#define MAX_PAGES_FOR_CHECKING (MAX_BYTES_FOR_CHECKING * 8) //*8 since we're coding one bit per page, checking whether it's accessed

uint64 sys_pgaccess() {
  uint64 virt_addr;
  argaddr(0, &virt_addr);
  int num_pages;
  argint(1, &num_pages);
  uint64 user_out_addr;
  argaddr(2, &user_out_addr);
  pagetable_t pagetable = myproc()->pagetable;
  
  if (num_pages > MAX_PAGES_FOR_CHECKING)
    num_pages = MAX_PAGES_FOR_CHECKING;

  unsigned char inner_out[MAX_BYTES_FOR_CHECKING];
  memset(inner_out, 0, sizeof inner_out);
  for (int page_index = 0; page_index < num_pages; ++page_index, virt_addr += PGSIZE) {
    pte_t *pte = walk(pagetable, virt_addr, 0);
    if (!pte)
      continue;
    if (*pte & PTE_A) {
      inner_out[page_index / 8] |= 1 << (page_index % 8);
      *pte ^= PTE_A;
    }
  }
  return copyout(pagetable, user_out_addr, (char *)inner_out, ((num_pages + 7) / 8));
}