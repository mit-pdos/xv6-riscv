#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void printer(int index, uint64 pte, uint64 addr, int depth){
    short pte_d = ((pte & PTE_D)? 1 : 0);
    short pte_a = ((pte & PTE_A)? 1 : 0);
    short pte_g = ((pte & PTE_G)? 1 : 0);
    short pte_u = ((pte & PTE_U)? 1 : 0);
    short pte_x = ((pte & PTE_X)? 1 : 0);
    short pte_w = ((pte & PTE_W)? 1 : 0);
    short pte_r = ((pte & PTE_R)? 1 : 0);
    short pte_v = ((pte & PTE_V)? 1 : 0);
    for(int d = 0; d < depth; d++)
        printf("---");
    printf("> ");
    if (index >= 0)
      printf("%d: ", index);
    printf("pte %p pa %p pte_D %d pte_A %d pte_G %d pte_U %d pte_X %d pte_W %d pte_R %d pte_V %d \n", 
      pte, addr,pte_d, pte_a, pte_g, pte_u, pte_x, pte_w, pte_r, pte_v);
}

struct spinlock spin_vmprint;

struct spinlock spin_pgaccess;

void display_table_lock_init(){
    initlock(&spin_vmprint, "spin_vmprint");
    initlock(&spin_pgaccess, "spin_pgaccess");
}

//task_1

//%-------------------------------------------------------

void vmprint_helper(pagetable_t pagetable, int depth) {
  for(int i = 0; i < 512; i++){
    uint64 pte = pagetable[i];

    if(pte & PTE_V) {
      uint64 next = PTE2PA(pte);

      printer(i, pte, next, depth);
      if((pte & (PTE_R | PTE_W | PTE_X)) == 0)
          vmprint_helper((pagetable_t)next, depth + 1);
    } 
  }
}

void vmprint() {
  acquire(&spin_vmprint);   
  pagetable_t pagetable = myproc() -> pagetable;

  printf("pid %d\n", myproc() -> pid);    
  printf("page table %p\n", pagetable);

  vmprint_helper(pagetable, 0);

  release(&spin_vmprint);   
}

uint64
sys_vmprint(void)
{
    vmprint();
    return 0;
}

//task_2

//%-------------------------------------------------------

void pgaccess_helper(pagetable_t pagetable, int depth) {
  for(int i = 0; i < 512; i++){
    uint64 pte = pagetable[i];

    if((pte & PTE_V)) {
      uint64 next = PTE2PA(pte);
      pagetable[i] &= ~(PTE_A);
      if (pte & PTE_A) {
        printer(-1, pte, next, 0);
      }
      if((pte & (PTE_R | PTE_W | PTE_X)) == 0)
          pgaccess_helper((pagetable_t)next, depth + 1);
    } 
  }
}

void pgaccess() {
  acquire(&spin_pgaccess);
  pagetable_t pagetable = myproc() -> pagetable;

  printf("pid %d\n", myproc() -> pid);    
  printf("page table %p\n", pagetable);

  pgaccess_helper(pagetable, 0);
  
  release(&spin_pgaccess);
}

uint64
sys_pgaccess(void)
{
    pgaccess();
    return 0;
}