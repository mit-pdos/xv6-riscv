// kernel/shm.c

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

// --- Global variables for a single shared memory page ---

// Controls access to the shared page and its metadata
static struct spinlock shm_lock;

// Pointer to the single, shared physical page. Null if not allocated.
static char *shm_page = 0;

// Tracks how many processes are currently using the shared page.
static int shm_ref_count = 0;


// --- System Call Implementations ---

void
shm_init(void)
{
  initlock(&shm_lock, "shm");
}

// Creates and attaches the single shared page.
// The 'key' is ignored as there is only one page. Returns 0 on success.
int
shm_create(int key)
{
  struct proc *p = myproc();

  acquire(&shm_lock);

  // If the shared page doesn't exist yet, create it.
  if(shm_page == 0) {
    shm_page = kalloc();
    if(shm_page == 0){
      release(&shm_lock);
      return -1; // Allocation failed
    }
    memset(shm_page, 0, PGSIZE); // Clear the new page
  }

  // Map the page into this process's virtual address space at the top.
  uint64 va = p->sz;
  if(mappages(p->pagetable, va, PGSIZE, (uint64)shm_page, PTE_W|PTE_R|PTE_U) != 0) {
    // If mapping fails, and no other process is using the page, free it.
    if(shm_ref_count == 0) {
      kfree(shm_page);
      shm_page = 0;
    }
    release(&shm_lock);
    return -1; // Return -1 on failure
  }

  // Grow the process size to include the new page
  p->sz += PGSIZE;
  // Increment the reference count for the new attachment
  shm_ref_count++;

  release(&shm_lock);
  return 0; // Return 0 for success
}

// Gets the virtual address of the already attached shared page.
// Note: In this simplified model, create() and get() are combined.
// This function could be adapted, but for now, we assume create() is the entry point.
void*
shm_get(int key)
{
  // For this model, shm_create should be used to get and map the page.
  // If a process wants the VA of an already mapped page, it should store it.
  // Returning an error or a specific value can indicate this design choice.
  // For compatibility, we can search if it's already mapped.
  struct proc *p = myproc();
  if(shm_page != 0){
      for(uint64 va = 0; va < p->sz; va += PGSIZE) {
          pte_t* pte = walk(p->pagetable, va, 0);
          if (pte && (*pte & PTE_V) && (PTE2PA(*pte) == (uint64)shm_page)) {
              return (void*)va;
          }
      }
  }
  return (void*)-1; // Not found or not created
}

// Detaches the shared page from the calling process's memory.
int
shm_close(int key)
{
  struct proc *p = myproc();

  acquire(&shm_lock);

  if(shm_page == 0 || shm_ref_count <= 0){
    release(&shm_lock);
    return -1; // Nothing to close
  }

  // Find the virtual address of the shared page in this process
  uint64 va = 0;
  for(uint64 a = 0; a < p->sz; a += PGSIZE) {
      pte_t* pte = walk(p->pagetable, a, 0);
      if (pte && (*pte & PTE_V) && (PTE2PA(*pte) == (uint64)shm_page)) {
          va = a;
          break;
      }
  }

  if (va == 0) {
      // This process doesn't seem to have the page mapped.
      release(&shm_lock);
      return -1;
  }
  
  // Decrement the reference count as this process is detaching
  shm_ref_count--;

  // Unmap the page from this process's address space
  // Use uvmunmap instead of uvmdealloc to avoid size issues
  uvmunmap(p->pagetable, va, 1, 0);
  
  // Adjust process size if the shared memory was at the end
  if(va == p->sz - PGSIZE) {
    p->sz -= PGSIZE;
  }

  // If this was the last process using the page, free the physical page
  if(shm_ref_count == 0) {
    kfree(shm_page);
    shm_page = 0;
  }

  release(&shm_lock);
  return 0;
}

// Cleans up a process's shared memory attachment on exit.
void
shm_cleanup(struct proc *p)
{
  acquire(&shm_lock);

  if (shm_page != 0) {
      // Scan the page table to see if the exiting process had the page mapped.
      for (uint64 va = 0; va < p->sz; va += PGSIZE) {
          pte_t *pte = walk(p->pagetable, va, 0);
          if (pte && (*pte & PTE_V) && (PTE2PA(*pte) == (uint64)shm_page)) {
              // Found it. Decrement ref count and clean up if it's the last one.
              shm_ref_count--;
              if (shm_ref_count == 0) {
                  kfree(shm_page);
                  shm_page = 0;
              }
              // Note: We don't unmap here as the process is exiting
              // and its page table will be freed anyway
              break; // Found and handled
          }
      }
  }
  
  release(&shm_lock);
}