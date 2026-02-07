// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"


int refcnt[PHYSTOP / PGSIZE];
struct spinlock refcnt_lock;

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

void
kinit()
{ 
  initlock(&refcnt_lock, "refcnt");
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

void freerange(void *pa_start, void *pa_end)
{
  char *p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    acquire(&refcnt_lock);
    refcnt[(uint64)p / PGSIZE] = 0;  // start with 0, truly free
    release(&refcnt_lock);
    kfree(p);
  }
}


//////////////////////

void incref(uint64 pa) {
  acquire(&refcnt_lock);
  refcnt[pa / PGSIZE]++;
  release(&refcnt_lock);
}
void decref(uint64 pa) {
  acquire(&refcnt_lock);
  if(--refcnt[pa / PGSIZE] == 0){
    release(&refcnt_lock);
    kfree((void*)pa);   // actually free the page
  } else {
    release(&refcnt_lock);
  }
}


/////////////////////


// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}



// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    struct run *r;

    acquire(&kmem.lock);
    r = kmem.freelist;
    if(r)
        kmem.freelist = r->next;
    release(&kmem.lock);

    if(r){
        // Fill with junk to catch dangling refs.
        memset((char*)r, 5, PGSIZE);

        // Initialize reference count to 1 for this new page
        acquire(&refcnt_lock);
        refcnt[(uint64)r / PGSIZE] = 1;
        release(&refcnt_lock);
    }

    return (void*)r;
}








