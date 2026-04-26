#ifndef SWAP_H
#define SWAP_H

uint64 pick_victim(void); 
int add_swap_slot(struct proc *p, int slot);
int get_swap_slot_for_va(struct proc *p, uint64 va);
void remove_swap_slot(struct proc *p, int slot);
void mark_swapped_out(pagetable_t pagetable, uint64 va, int swap_slot);

#endif