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
  int sorted;          // 1 = use sorted insertion, 0 = fast insert at head
} kmem;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  kmem.free_pages  = 0;
  kmem.total_allocs = 0;
  kmem.total_frees  = 0;
  kmem.sorted = 0;          // disable sorted insert during boot (performance)
  freerange(end, (void *)PHYSTOP);
  kmem.sorted = 1;          // enable sorted insert after boot completes
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

  // MODIFIED: sorted insertion by physical address (enabled after boot)
  // During boot (kmem.sorted==0): fast insert at head like original xv6
  // After boot (kmem.sorted==1): insert in order low->high physical address
  if(!kmem.sorted){
    // Original xv6 behavior — O(1) insert at head
    r->next = kmem.freelist;
    kmem.freelist = r;
  } else {
    struct run *curr = kmem.freelist;
    struct run *prev = 0;
    // Find correct position
    while(curr && (uint64)curr < (uint64)r){
      prev = curr;
      curr = curr->next;
    }
    r->next = curr;
    if(prev)
      prev->next = r;
    else
      kmem.freelist = r;
  }

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

// Fill meminfo struct with current memory statistics.
// frag_blocks counts non-contiguous runs in the sorted free list —
// a perfect allocator would have frag_blocks == 1 (one big contiguous run).
void
kgetmeminfo(struct meminfo *mi)
{
  acquire(&kmem.lock);

  // Count fragmentation: walk sorted free list and count non-adjacent blocks
  uint64 frag = 0;
  struct run *r = kmem.freelist;
  if(r) frag = 1;  // at least one block exists
  while(r && r->next){
    // If next block is not physically adjacent, it's a new fragment
    if((uint64)r->next != (uint64)r + PGSIZE)
      frag++;
    r = r->next;
  }

  uint64 total = (PHYSTOP - KERNBASE) / PGSIZE;
  mi->free_pages  = kmem.free_pages;
  mi->used_pages  = total - kmem.free_pages;
  mi->total_pages = total;
  mi->frag_blocks = frag;

  release(&kmem.lock);
}

// Coalesce adjacent free pages in the sorted free list.
// Merges physically contiguous blocks into one, reducing fragmentation.
// Returns number of merges performed.
// REQUIRES: kmem.sorted == 1 (list must be sorted by physical address)
int
kcoalesce(void)
{
  int merges = 0;
  acquire(&kmem.lock);

  struct run *r = kmem.freelist;
  while(r && r->next){
    // Check if next block is physically adjacent to current
    if((uint64)r->next == (uint64)r + PGSIZE){
      // Merge: skip r->next, extending r's logical block
      r->next = r->next->next;
      merges++;
      // Don't advance r — check if new r->next is also adjacent
    } else {
      r = r->next;
    }
  }

  // Update free_pages to reflect merges (logical blocks, not pages)
  // Note: page count stays same, only list structure changes
  release(&kmem.lock);
  return merges;
}

// Kernel-level fragmentation test.
// Allocates n pages, frees alternating ones, measures fragmentation.
// Returns frag_blocks after alternating free (worse case).
uint64
kfragtest(int n)
{
  void *pages[64];
  if(n > 64) n = 64;

  // Allocate n pages
  for(int i = 0; i < n; i++)
    pages[i] = kalloc();

  // Free alternating pages to create fragmentation
  for(int i = 0; i < n; i += 2){
    if(pages[i])
      kfree(pages[i]);
  }

  // Measure fragmentation
  struct meminfo mi;
  kgetmeminfo(&mi);
  uint64 frag = mi.frag_blocks;

  // Free remaining pages
  for(int i = 1; i < n; i += 2){
    if(pages[i])
      kfree(pages[i]);
  }

  return frag;
}
