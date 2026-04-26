#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "stat.h"
#include "proc.h" 
#include "swap.h"    


#define NSWAP 64 //the swap slots are the max no. of pages that can be possibly swapped

extern struct spinlock ft_lock;
struct frame {
  int state;            // 0=free, 1=kernel, 2=user
  struct proc *owner;
  uint64 va;
};
extern struct frame frame_table[];

struct inode *swap_inode;
// inode is a data struct that holds the metadata of a file
char swap_free[NSWAP];  // 1 means slot is free
struct spinlock swap_lock;

// so we will have 3 main functions: swap_init(), swapout(pa, slot), swapin(pa, slot)



void swap_init() {
    initlock(&swap_lock, "swap");
     begin_op(); 
    // rootdev is tells the kernel to create the file on the root device, and T_FILE is to create a regular file.
    //what ialloc does is it allocates an inode on theh 
    swap_inode = ialloc(ROOTDEV, T_FILE);
    if(swap_inode == 0)
        panic("swap_init: ialloc failed");

    ilock(swap_inode);         
    swap_inode->size = NSWAP * PGSIZE;
    iupdate(swap_inode);
    iunlock(swap_inode);  
    end_op();       

    acquire(&swap_lock);
    for(int i = 0; i < NSWAP; i++)
        swap_free[i] = 1;
    release(&swap_lock);

    printf("swap_init: swap file created with %d slots\n", NSWAP);
}

void swapout(uint64 pa, int slot)
{
    if(slot < 0 || slot >= NSWAP)
        panic("swapout: invalid slot");
    printf("SWAP-OUT: slot %d, pa %p\n", slot, (void*)pa);

    begin_op();               
    ilock(swap_inode);
    int n = writei(swap_inode, 0, pa, slot * PGSIZE, PGSIZE);
    if(n != PGSIZE)
        panic("swapout: writei failed");
    iupdate(swap_inode);
    iunlock(swap_inode);
    end_op();                   

    kfree((void*)pa);
}

void swapin(uint64 pa, int slot)
{
    if(slot<0 || slot >=NSWAP){
        panic("swapin: invalid slot");
    }
    printf("SWAP-IN: slot %d, pa %p\n", slot, (void*)pa);
    ilock(swap_inode);

    int n = readi(swap_inode, 0, pa, slot*PGSIZE, PGSIZE);
    if(n!=PGSIZE){
        panic("swapin: readi failed");
    }
    iunlock(swap_inode);
    

}
int swap_alloc(void){
    acquire(&swap_lock);
    for(int i=0;i<NSWAP; i++){
        if(swap_free[i]){
            swap_free[i] = 0;
            release(&swap_lock);
            return i;
        }
    }
    release(&swap_lock);
    panic("swap_alloc: no free slots"); 
}

void swap_free_slot(int slot){
    if(slot<0 || slot >=NSWAP){
        panic("swap_free_slot: invalid slot");
    }
    acquire(&swap_lock);
    swap_free[slot] = 1;
    release(&swap_lock);
}

int add_swap_slot(struct proc *p, int slot) {
    acquire(&p->swap_lock);
    for(int i = 0; i < 16; i++) {
        if(p->swap_slots[i] == -1) {
            p->swap_slots[i] = slot;
            p->num_swapped++;
            release(&p->swap_lock);
            return 0;
        }
    }
    release(&p->swap_lock);
    return -1; 
}
    void remove_swap_slot(struct proc *p, int slot) {
    acquire(&p->swap_lock);
    for(int i = 0; i < 16; i++) {
        if(p->swap_slots[i] == slot) {
            p->swap_slots[i] = -1;
            p->num_swapped--;
            release(&p->swap_lock);
            return;
        }
    }
    release(&p->swap_lock);
}
int get_swap_slot_for_va(struct proc *p, uint64 va) {
    pte_t *pte = walk(p->pagetable, va, 0);
    if(pte == 0 || !is_swapped_out(pte))
        return -1;
    return get_swap_slot_from_pte(pte);
}
// Find a user page to kick out to disk
uint64
pick_victim(void)
{
  acquire(&ft_lock);
  for(int i = 0; i < PHYSTOP/PGSIZE; i++){
    // state 2 = user page, owner != 0 ensures it's actually assigned
    if(frame_table[i].state == 2 && frame_table[i].owner != 0){
      uint64 pa = (uint64)i * PGSIZE;
      release(&ft_lock);
      return pa;
    }
  }
  release(&ft_lock);
  return 0; // No user pages found to evict
}

// Update the PTE to mark it as swapped out
void
mark_swapped_out(pagetable_t pagetable, uint64 va, int slot)
{
  pte_t *pte = walk(pagetable, va, 0);
  if(pte == 0) 
    panic("mark_swapped_out: no pte");

  // Logic: Store slot in high bits, set SWAPPED flag, clear VALID flag
  *pte = (slot << 10) | PTE_SWAPPED;
  // *pte &= ~PTE_V; // The bitwise OR above already clears PTE_V if it's not included
}

