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

extern char end[];

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
  // MEMORY STATS: track free pages for fragmentation analysis
  uint64 free_pages;   // current number of free pages
  uint64 total_allocs; // total kalloc() calls
  uint64 total_frees;  // total kfree() calls
} kmem;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  kmem.free_pages  = 0;
  kmem.total_allocs = 0;
  kmem.total_frees  = 0;
  freerange(end, (void *)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa.
// MODIFIED: also updates free_pages and total_frees counters.
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run *)pa;

  acquire(&kmem.lock);

  // MODIFIED: insert in sorted order by physical address
  // This is the prerequisite for coalescence and reduces fragmentation
  // Original xv6 inserted at head regardless of address (unordered)
  struct run *curr = kmem.freelist;
  struct run *prev = 0;

  // Find correct position: keep list sorted low->high address
  while(curr && (uint64)curr < (uint64)r){
    prev = curr;
    curr = curr->next;
  }

  // Insert r between prev and curr
  r->next = curr;
  if(prev)
    prev->next = r;
  else
    kmem.freelist = r;   // r is new head (lowest address)

  // MEMORY STATS: update counters
  kmem.free_pages++;
  kmem.total_frees++;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// MODIFIED: also updates free_pages and total_allocs counters.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r){
    kmem.freelist = r->next;
    // MEMORY STATS: decrement free page counter
    kmem.free_pages--;
    kmem.total_allocs++;
  }
  release(&kmem.lock);

  if(r)
    memset((char *)r, 5, PGSIZE); // fill with junk
  return (void *)r;
}

// Return number of free pages currently available.
// ADDED: exposes memory stats for analysis and testing.
uint64
kfreepages(void)
{
  uint64 n;
  acquire(&kmem.lock);
  n = kmem.free_pages;
  release(&kmem.lock);
  return n;
}

// Print memory statistics to console.
// ADDED: useful for before/after comparison in report.
void
kprintmemstats(void)
{
  acquire(&kmem.lock);
  printk("=== Memory Stats ===\n");
  printk("Free pages   : %ld\n", kmem.free_pages);
  printk("Total allocs : %ld\n", kmem.total_allocs);
  printk("Total frees  : %ld\n", kmem.total_frees);
  printk("====================\n");
  release(&kmem.lock);
}
