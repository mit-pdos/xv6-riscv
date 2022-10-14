// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"


int ref_count[PHYSTOP / PGSIZE]; // create ref_count to maintain the reference count for every physical page
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
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

void freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
  {
    ref_count[(uint64)p / PGSIZE] = 1;
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  r = (struct run *)pa;

  acquire(&kmem.lock);
  int page_num = (uint64)r / PGSIZE; // get the page number
  if (ref_count[page_num] < 1)       // if the reference count is 0, free the page
    panic("kfree");
  ref_count[page_num]--;
  int temp_count = ref_count[page_num];
  release(&kmem.lock);

  if (temp_count > 0)
  {
    return;
  }
  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

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
  if (r)
  {
    if (ref_count[(uint64)r / PGSIZE] != 0)
      panic("kalloc");                 // if the pa ref cnt is not valid , panic.
    ref_count[(uint64)r / PGSIZE] = 1; // set the reference count to 1
    kmem.freelist = r->next;
  }
  release(&kmem.lock);

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
  return (void *)r;
}

void increase(uint64 pa)
{
  acquire(&kmem.lock);

  if (ref_count[pa / PGSIZE] == 0 || ref_count[pa / PGSIZE] < 1 || pa > PHYSTOP)
    panic("increase");
  ref_count[pa / PGSIZE]++;
  release(&kmem.lock);
}

int cowfault(uint64 va, pagetable_t pagetable)
{
  if (va >= MAXVA)
    return -1;
  uint64 pa;
  uint64 mem;
  pte_t *pte;
  pte = walk(pagetable, va, 0);
  if (pte == 0)
    return -1;
  if (!(*pte & PTE_V))
    return -1;
  if(!(*pte & PTE_U))
    return -1;
  // if (!(*pte & PTE_COW))
  //   return 0;

  pa = PTE2PA(*pte);

  mem = (uint64)kalloc();
  if (mem == 0)
    return -1;
  memmove((void *)mem, (void *)pa, PGSIZE);
  *pte = PA2PTE(mem) | PTE_V | PTE_R | PTE_W | PTE_X | PTE_U;
  kfree((void *)pa);

  return 0;
}