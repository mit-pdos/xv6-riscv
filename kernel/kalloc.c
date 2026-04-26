// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

// Frame Table for tracking physical memory ownership
struct spinlock ft_lock;

struct frame {
  int state;            // 0=free, 1=kernel, 2=user
  struct proc *owner;
  uint64 va;
} frame_table[PHYSTOP/PGSIZE];

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
  initlock(&ft_lock, "ft_lock");   // Initialize the Frame Table lock
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

// Free the page of physical memory pointed at by pa
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // --- CRITICAL UPDATE FOR SWAPPING ---
  // Mark the frame as FREE in the frame table before returning it to freelist
  acquire(&ft_lock);
  frame_table[(uint64)pa / PGSIZE].state = 0;
  frame_table[(uint64)pa / PGSIZE].owner = 0;
  release(&ft_lock);

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}

// Track which process and VA are using a physical frame
void
kalloc_user_map(uint64 pa, struct proc *p, uint64 va)
{
  int idx = pa / PGSIZE;
  acquire(&ft_lock);
  frame_table[idx].state = 2; // Mark as USER page
  frame_table[idx].owner = p;
  frame_table[idx].va = va;
  release(&ft_lock);
}