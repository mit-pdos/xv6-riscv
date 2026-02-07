#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "memlayout.h"
#include "vm.h"

#define MAX_SWAP_SLOTS 512
#define SWAP_IN_QUEUE 128

extern struct proc proc[NPROC];
extern struct proc *initproc;

struct swap_slot {
  int used;
  int pid;
  uint64 va;
  uint64 perm;
  char data[PGSIZE];
};

struct swap_in_request {
  struct proc *proc;
  uint64 va;
};

static struct spinlock swap_out_lock;
static struct spinlock swap_slots_lock;
static struct spinlock swap_in_queue_lock;
static char swap_out_chan;
static char swap_free_chan;
static char swap_in_chan;

static int swap_out_waiters;

static struct swap_slot swap_slots[MAX_SWAP_SLOTS];
static struct swap_in_request swap_in_queue[SWAP_IN_QUEUE];
static int swap_in_head;
static int swap_in_tail;

static void swap_out_main(void) __attribute__((noreturn));
static void swap_in_main(void) __attribute__((noreturn));

static int swap_out_one_page(void);
static struct proc* choose_victim(uint64 *va_out);
static uint64 find_candidate_va(struct proc *p);
static int alloc_swap_slot(struct proc *p, uint64 va, uint64 perm);
static void release_swap_slot(int slot);
static struct swap_entry* proc_swap_entry_get(struct proc *p, uint64 va, int create);
static void enqueue_swap_in(struct proc *p, uint64 va);
static void perform_swap_in(struct proc *p, uint64 va);
static void wake_waiters(void);

static void
wake_waiters(void)
{
  acquire(&swap_out_lock);
  wakeup(&swap_free_chan);
  release(&swap_out_lock);
}

void
swap_request_memory(void)
{
  acquire(&swap_out_lock);
  swap_out_waiters++;
  wakeup(&swap_out_chan);
  sleep(&swap_free_chan, &swap_out_lock);
  if(swap_out_waiters > 0)
    swap_out_waiters--;
  release(&swap_out_lock);
}

static void
swap_out_main(void)
{
  for(;;){
    acquire(&swap_out_lock);
    while(swap_out_waiters == 0)
      sleep(&swap_out_chan, &swap_out_lock);
    release(&swap_out_lock);

    if(swap_out_one_page() == 0)
      wake_waiters();
    else
      wake_waiters();
  }
}

static int
dequeue_swap_in(struct proc **pp, uint64 *va)
{
  acquire(&swap_in_queue_lock);
  while(swap_in_head == swap_in_tail)
    sleep(&swap_in_chan, &swap_in_queue_lock);

  struct swap_in_request req = swap_in_queue[swap_in_head];
  swap_in_head = (swap_in_head + 1) % SWAP_IN_QUEUE;
  release(&swap_in_queue_lock);

  *pp = req.proc;
  *va = req.va;
  return 0;
}

static void
swap_in_main(void)
{
  struct proc *p;
  uint64 va;
  for(;;){
    if(dequeue_swap_in(&p, &va) == 0)
      perform_swap_in(p, va);
  }
}

static void
enqueue_swap_in(struct proc *p, uint64 va)
{
  acquire(&swap_in_queue_lock);
  int next_tail = (swap_in_tail + 1) % SWAP_IN_QUEUE;
  if(next_tail == swap_in_head){
    release(&swap_in_queue_lock);
    panic("swap queue full");
  }
  swap_in_queue[swap_in_tail].proc = p;
  swap_in_queue[swap_in_tail].va = va;
  swap_in_tail = next_tail;
  wakeup(&swap_in_chan);
  release(&swap_in_queue_lock);
}

static struct swap_entry*
proc_swap_entry_get(struct proc *p, uint64 va, int create)
{
  uint64 page = PGROUNDDOWN(va);
  for(int i = 0; i < MAX_SWAP_PAGES; i++){
    if(p->swap_entries[i].used && p->swap_entries[i].va == page)
      return &p->swap_entries[i];
  }
  if(!create)
    return 0;
  for(int i = 0; i < MAX_SWAP_PAGES; i++){
    if(!p->swap_entries[i].used){
      p->swap_entries[i].used = 1;
      p->swap_entries[i].va = page;
      p->swap_entries[i].slot = -1;
      p->swap_entries[i].perm = 0;
      return &p->swap_entries[i];
    }
  }
  return 0;
}

static int
alloc_swap_slot(struct proc *p, uint64 va, uint64 perm)
{
  int slot = -1;
  acquire(&swap_slots_lock);
  for(int i = 0; i < MAX_SWAP_SLOTS; i++){
    if(!swap_slots[i].used){
      swap_slots[i].used = 1;
      swap_slots[i].pid = p->pid;
      swap_slots[i].va = va;
      swap_slots[i].perm = perm;
      slot = i;
      break;
    }
  }
  release(&swap_slots_lock);
  return slot;
}

static void
release_swap_slot(int slot)
{
  if(slot < 0 || slot >= MAX_SWAP_SLOTS)
    return;
  acquire(&swap_slots_lock);
  swap_slots[slot].used = 0;
  swap_slots[slot].pid = 0;
  swap_slots[slot].va = 0;
  swap_slots[slot].perm = 0;
  release(&swap_slots_lock);
}

static uint64
find_candidate_va(struct proc *p)
{
  uint64 candidate = 0;
  for(uint64 va = PGSIZE; va < p->sz; va += PGSIZE){
    pte_t *pte = walk(p->pagetable, va, 0);
    if(pte == 0)
      continue;
    if((*pte & PTE_V) && (*pte & PTE_U) && ((*pte & PTE_SWAP) == 0)){
      candidate = va;
      break;
    }
  }
  return candidate;
}

static struct proc*
choose_victim(uint64 *va_out)
{
  struct proc *victim = 0;
  *va_out = 0;
  for(struct proc *p = proc; p < &proc[NPROC]; p++){
    if(p == initproc)
      continue;
    if(p->state == UNUSED || p->is_kernel)
      continue;
    acquire(&p->lock);
    if(p->state == UNUSED || p->pagetable == 0){
      release(&p->lock);
      continue;
    }
    uint64 cand = find_candidate_va(p);
    if(cand != 0){
      victim = p;
      *va_out = cand;
      break;
    }
    release(&p->lock);
  }
  return victim;
}

static int
swap_out_one_page(void)
{
  uint64 va = 0;
  struct proc *p = choose_victim(&va);
  if(p == 0)
    return -1;

  pte_t *pte = walk(p->pagetable, va, 0);
  if(pte == 0 || (*pte & PTE_V) == 0){
    release(&p->lock);
    return -1;
  }

  uint64 perm = *pte & (PTE_R|PTE_W|PTE_X|PTE_U);
  uint64 pa = PTE2PA(*pte);

  int slot = alloc_swap_slot(p, va, perm);
  if(slot < 0){
    release(&p->lock);
    return -1;
  }

  memmove(swap_slots[slot].data, (char*)pa, PGSIZE);

  struct swap_entry *entry = proc_swap_entry_get(p, va, 1);
  if(entry == 0){
    release_swap_slot(slot);
    release(&p->lock);
    return -1;
  }

  entry->slot = slot;
  entry->perm = perm;

  kfree((void*)pa);

  *pte = ((uint64)slot << PGSHIFT) | perm | PTE_SWAP;
  sfence_vma();

  release(&p->lock);
  return 0;
}

static void
perform_swap_in(struct proc *p, uint64 va)
{
  acquire(&p->lock);
  if(p->state == UNUSED || p->pagetable == 0){
    release(&p->lock);
    return;
  }

  uint64 page = PGROUNDDOWN(va);
  pte_t *pte = walk(p->pagetable, page, 0);
  if(pte == 0 || (*pte & PTE_SWAP) == 0){
    release(&p->lock);
    return;
  }

  int slot = PTE_SWAP_SLOT(*pte);
  uint64 perm = *pte & (PTE_R|PTE_W|PTE_X|PTE_U);

  char *mem;
  while((mem = kalloc()) == 0){
    release(&p->lock);
    swap_request_memory();
    acquire(&p->lock);
    if(p->state == UNUSED || p->pagetable == 0)
      return;
    pte = walk(p->pagetable, page, 0);
    if(pte == 0 || (*pte & PTE_SWAP) == 0)
      return;
  }

  acquire(&swap_slots_lock);
  if(slot < 0 || slot >= MAX_SWAP_SLOTS || !swap_slots[slot].used){
    release(&swap_slots_lock);
    kfree(mem);
    release(&p->lock);
    return;
  }
  memmove(mem, swap_slots[slot].data, PGSIZE);
  perm = swap_slots[slot].perm;
  swap_slots[slot].used = 0;
  swap_slots[slot].pid = 0;
  swap_slots[slot].va = 0;
  swap_slots[slot].perm = 0;
  release(&swap_slots_lock);

  *pte = PA2PTE((uint64)mem) | perm | PTE_V;
  sfence_vma();

  struct swap_entry *entry = proc_swap_entry_get(p, page, 0);
  if(entry){
    entry->used = 0;
    entry->slot = -1;
    entry->perm = 0;
  }

  wakeup(&p->swap_wait_chan);
  release(&p->lock);
}

int
swap_handle_fault(struct proc *p, uint64 va)
{
  uint64 page = PGROUNDDOWN(va);
  pte_t *pte = walk(p->pagetable, page, 0);
  if(pte == 0 || (*pte & PTE_SWAP) == 0)
    return -1;

  enqueue_swap_in(p, page);
  sleep(&p->swap_wait_chan, &p->lock);
  return 0;
}

void
swap_remove_proc(struct proc *p)
{
  for(int i = 0; i < MAX_SWAP_PAGES; i++){
    if(p->swap_entries[i].used){
      release_swap_slot(p->swap_entries[i].slot);
      p->swap_entries[i].used = 0;
      p->swap_entries[i].slot = -1;
      p->swap_entries[i].va = 0;
      p->swap_entries[i].perm = 0;
    }
  }
}

int
swap_copy_page(struct proc *p, uint64 va, char *dst, uint64 *perm)
{
  int rc = -1;
  acquire(&p->lock);
  struct swap_entry *entry = proc_swap_entry_get(p, va, 0);
  if(entry && entry->used){
    acquire(&swap_slots_lock);
    int slot = entry->slot;
    if(slot >= 0 && slot < MAX_SWAP_SLOTS && swap_slots[slot].used){
      memmove(dst, swap_slots[slot].data, PGSIZE);
      if(perm)
        *perm = entry->perm;
      rc = 0;
    }
    release(&swap_slots_lock);
  }
  release(&p->lock);
  return rc;
}

void
swap_remove_range(struct proc *p, uint64 start, uint64 end)
{
  if(start >= end)
    return;
  for(int i = 0; i < MAX_SWAP_PAGES; i++){
    if(!p->swap_entries[i].used)
      continue;
    uint64 va = p->swap_entries[i].va;
    if(va >= start && va < end){
      release_swap_slot(p->swap_entries[i].slot);
      p->swap_entries[i].used = 0;
      p->swap_entries[i].slot = -1;
      p->swap_entries[i].va = 0;
      p->swap_entries[i].perm = 0;
    }
  }
}

void
swap_init(void)
{
  initlock(&swap_out_lock, "swapout");
  initlock(&swap_slots_lock, "swapslots");
  initlock(&swap_in_queue_lock, "swapinq");
  swap_out_waiters = 0;
  swap_in_head = 0;
  swap_in_tail = 0;

  create_kernel_process("kswapout", swap_out_main);
  create_kernel_process("kswapin", swap_in_main);
}

