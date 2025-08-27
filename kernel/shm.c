// kernel/shm.c

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

struct shm_mapping {
  struct proc *proc;    // Which process has this mapping
  uint64 va;           // Virtual address in that process
  int valid;           // Is this mapping slot used?
};

struct spinlock shm_lock; // Lock for shared page
char *shm_page = 0;      // Pointer to the physical page
int shm_ref_count = 0; 
struct shm_mapping shm_mappings[NPROC]; // Track mappings per process

void
shminit(void)
{
  initlock(&shm_lock, "shm");
  for(int i = 0; i < NPROC; i++) {
    shm_mappings[i].valid = 0;
  }
}

uint64
shm_get(int key)
{
  struct proc *p = myproc();
  
  acquire(&shm_lock);
  
  // Check if this process already has a mapping
  for(int i = 0; i < NPROC; i++) {
    if(shm_mappings[i].valid && shm_mappings[i].proc == p) {
      release(&shm_lock);
      return shm_mappings[i].va; // Return existing mapping
    }
  }
  
  if(shm_page == 0) {
    shm_page = kalloc();
    if(shm_page == 0){
      release(&shm_lock);
      return 0;
    }
    memset(shm_page, 0, PGSIZE);
    shm_ref_count = 0;
  }
  
  shm_ref_count++;
  release(&shm_lock);
  
  uint64 va = p->sz; 
  if (mappages(p->pagetable, va, PGSIZE, (uint64)shm_page, PTE_W | PTE_R | PTE_U) != 0) {
    acquire(&shm_lock);
    shm_ref_count--;
    if(shm_ref_count == 0) {
      kfree(shm_page);
      shm_page = 0;
    }
    release(&shm_lock);
    return 0;
  }
  p->sz += PGSIZE;
  
  // Store the mapping
  acquire(&shm_lock);
  for(int i = 0; i < NPROC; i++) {
    if(!shm_mappings[i].valid) {
      shm_mappings[i].proc = p;
      shm_mappings[i].va = va;
      shm_mappings[i].valid = 1;
      break;
    }
  }
  release(&shm_lock);
  
  return va;
}

// shm_close decrements the reference count of the shared page.
// If the count reaches 0, it frees the page.
// Also unmaps the virtual memory from the calling process.
int
shm_close(int key)
{
  struct proc *p = myproc();
  uint64 va = 0;
  
  acquire(&shm_lock);
  
  // Find this process's mapping
  for(int i = 0; i < NPROC; i++) {
    if(shm_mappings[i].valid && shm_mappings[i].proc == p) {
      va = shm_mappings[i].va;
      shm_mappings[i].valid = 0; // Mark as free
      break;
    }
  }
  
  if(va == 0) {
    release(&shm_lock);
    return -1; // No mapping found for this process
  }
  
  if(shm_page == 0 || shm_ref_count <= 0){
    release(&shm_lock);
    return -1;
  }

  shm_ref_count--;
  
  int should_free = (shm_ref_count == 0);
  if(should_free) {
    kfree(shm_page);
    shm_page = 0;
  }
  
  release(&shm_lock);
  
  // Unmap the virtual memory (do this after releasing the lock)
  // if(uvmunmap(p->pagetable, va, 1, 0) != 0) {
  //   return -1; // Failed to unmap
  // }
  uvmunmap(p->pagetable, va, 1, 0);
  p->sz -= PGSIZE;
  
  return 0;
}

// Function to clean up shared memory when a process exits
// This should be called from exit() in proc.c
void
shm_cleanup_proc(struct proc *p)
{
  acquire(&shm_lock);
  
  for(int i = 0; i < NPROC; i++) {
    if(shm_mappings[i].valid && shm_mappings[i].proc == p) {
      shm_mappings[i].valid = 0;
      
      if(shm_ref_count > 0) {
        shm_ref_count--;
        if(shm_ref_count == 0 && shm_page != 0) {
          kfree(shm_page);
          shm_page = 0;
        }
      }
    }
  }
  
  release(&shm_lock);
}