#include "types.h"
#include "fcntl.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"

static MappedMem *getMappedMem(struct proc *p, uint64 va) {
  for (int i = 0; i < NMAPPEDMEM; i++) {
    MappedMem *mm = &p->mappedMem[i];
    if ((mm->addr <= va) && (va < mm->addr + mm->len)) {
      return mm;
    }
  }

  return 0;
}

int fillMappedPage(uint64 va) {
  uint64 pa = 0;
  struct proc *p = myproc();
  if (walkaddr(p->pagetable, va) != 0) {
    goto failed;
  }

  MappedMem *mm = getMappedMem(p, va);
  if (mm == 0) {
    goto failed;
  }

  uint offset = PGROUNDDOWN(va - mm->addr);
  uint64 size = PGSIZE;
  if (PGROUNDDOWN(va) == PGROUNDDOWN(mm->addr + mm->len)) {
    size = mm->len % PGSIZE;
  }

  if ((pa = (uint64)kalloc()) == 0) {
    goto failed;
  }

  int perm = 0;
  if (mm->prot & PROT_READ) perm |= PTE_R;
  if (mm->prot & PROT_WRITE) perm |= PTE_W;

  // for now, we grant RW access to this page so that we can write to it.
  // we will revoke these later;
  if (mappages(p->pagetable, PGROUNDDOWN(va), PGSIZE, pa, PTE_R | PTE_W | PTE_U) == -1) {
    goto failed;
  }
  
  int r = 0;
  ilock(mm->file->ip);
  if ((r = readi(mm->file->ip, 1, PGROUNDDOWN(va), offset, size)) != size) {
    uvmunmap(p->pagetable, PGROUNDDOWN(va), 1, 0);
    iunlock(mm->file->ip);
    goto failed;
  }
  iunlock(mm->file->ip);

  // now that we have written to this page, we can set the permissions.
  pte_t *pte = walk(p->pagetable, va, 0);
  if (pte == 0) {
    // we should be here! something went horribly wrong.
    panic("fillMappedPage: walk");
  }
  *pte &= ~(PTE_W | PTE_R);
  *pte |= perm;

  return 0;

failed:
  if (pa != 0) {
    kfree((void *)pa);
  }
  return -1;
}

void *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset) {
  if (addr != 0) {
    return (void *)MMAP_FAILED;
  }

  if (offset != 0) {
    return (void *)MMAP_FAILED;
  }

  prot = prot & (PROT_READ | PROT_WRITE);
  if (prot == 0) {
    return (void *)MMAP_FAILED;
  }

  struct proc *p = myproc();
  struct file *f = p->ofile[fd];
  if (f->type != FD_INODE) {
    return (void *)MMAP_FAILED;
  }

  MappedMem *mm = 0;
  
  for (int i = 0; i < NMAPPEDMEM; i++) {
    if (p->mappedMem[i].addr == 0) {
      mm = &p->mappedMem[i];
      break;
    }
  }

  if (mm == 0) {
    return (void *)MMAP_FAILED;
  }
  
  mm->file = filedup(f);
  mm->len = len;
  mm->addr = growproclazy(len);
  mm->flags = flags & (MAP_PRIVATE | MAP_SHARED);
  mm->prot = prot & (PROT_READ | PROT_WRITE);

  return (void *)mm->addr;
}

