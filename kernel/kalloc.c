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

static uint8 *refcount;

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
  initlock(&kmem.lock, "kmem");

  uint refcountsize = PGROUNDUP((PHYSTOP - KERNBASE) / PGSIZE);
  refcount = (uint8 *)end;
  memset(refcount, 1, refcountsize);

  freerange(end + refcountsize, (void*)PHYSTOP);
}

uint8 *krefcount(void *pa) {
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("krefcount");

  int idx = ((uint64)pa - KERNBASE) / PGSIZE;
  return &refcount[idx];
}

void kaddref(void *pa) {
  uint8 *rc = krefcount(pa);
  (*rc)++;
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Decrement the ref count of physical page and 
// if possible, free the page of physical memory 
// pointed at by pa, which normally should have 
// been returned by a call to kalloc().  
// (The exception is when initializing the allocator; 
// see kinit above.)
void
kfree(void *pa)
{
  uint8 *rc = krefcount(pa);
  (*rc)--;

  if (*rc < 0) panic("kremref: invalid rc");
  if (*rc > 0) return;
  
  struct run *r;

  // Fill with junk.
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

  if(r) {
    kaddref((char *)r);
    memset((char*)r, 5, PGSIZE); // fill with junk
  }

  return (void*)r;
}
