// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

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

// Per-page reference counts for CoW support.
// Index by pa/PGSIZE; array sized for all physical pages up to PHYSTOP.
struct {
  struct spinlock lock;
  int count[PHYSTOP / PGSIZE];
} pageref;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  initlock(&pageref.lock, "pageref");
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Decrement reference count. Only free when it reaches 0.
  // During boot (freerange), counts are 0; handle gracefully.
  acquire(&pageref.lock);
  if(pageref.count[(uint64)pa / PGSIZE] > 0)
    pageref.count[(uint64)pa / PGSIZE]--;
  int remaining = pageref.count[(uint64)pa / PGSIZE];
  release(&pageref.lock);

  if(remaining > 0)
    return;

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
    memset((char*)r, 5, PGSIZE); // fill with junk
    // Initialize reference count to 1 for the new allocation.
    acquire(&pageref.lock);
    pageref.count[(uint64)r / PGSIZE] = 1;
    release(&pageref.lock);
  }
  return (void*)r;
}

// Increment the reference count for a physical page.
void
ref_incr(uint64 pa)
{
  acquire(&pageref.lock);
  pageref.count[pa / PGSIZE]++;
  release(&pageref.lock);
}

// Return the reference count for a physical page.
int
ref_count(uint64 pa)
{
  return pageref.count[pa / PGSIZE];
}
