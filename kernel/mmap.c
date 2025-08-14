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
  memset((char *)pa, 0, PGSIZE);

  int perm = 0;
  if (mm->prot & PROT_READ) perm |= PTE_R;
  if (mm->prot & PROT_WRITE) perm |= PTE_W;

  if (mappages(p->pagetable, PGROUNDDOWN(va), PGSIZE, pa, perm | PTE_U) == -1) {
    goto failed;
  }
  
  int r = 0;
  ilock(mm->file->ip);
  if ((r = readi(mm->file->ip, 0, pa, offset, size)) < 0) {
    uvmunmap(p->pagetable, PGROUNDDOWN(va), 1, 0);
    iunlock(mm->file->ip);
    goto failed;
  }
  iunlock(mm->file->ip);

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

  if (len % PGSIZE) {
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
  if (f->writable == 0 && (prot & PROT_WRITE) && (flags & MAP_SHARED)) {
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
  mm->orgAddr = mm->addr;
  mm->flags = flags & (MAP_PRIVATE | MAP_SHARED);
  mm->prot = prot & (PROT_READ | PROT_WRITE);

  return (void *)mm->addr;
}

static int writePageToFile(struct file *f, uint64 pa, off_t offset) {
  begin_op();
  ilock(f->ip);

  if (writei(f->ip, 0, pa, offset, PGSIZE) != PGSIZE) {
    iunlock(f->ip);
    end_op();
    return -1;
  }

  iunlock(f->ip);
  end_op();
  return 0;
}

static int unmapPage(struct proc *p, MappedMem *mm, uint64 va) {
  pte_t *pte = walk(p->pagetable, va, 0);
  if (pte == 0) {
    return -1;
  }

  if (!(*pte & ~PTE_V)) return 0;


  if ((*pte & PTE_D) && (mm->flags & MAP_SHARED) 
      && writePageToFile(mm->file, PTE2PA(*pte), va - mm->orgAddr) == -1) {
    return -1;
  }

  *pte &= ~PTE_V;
  kfree((void *)PTE2PA(*pte));

  return 0;
}

static int unmapPrefix(struct proc *p, MappedMem *mm, size_t len) {
  for (uint64 va = mm->addr; va < mm->addr + len; va += PGSIZE) {
    if (unmapPage(p, mm, va) == -1) return -1;
  }
 
  uvmunmap(p->pagetable, mm->addr, len / PGSIZE, 1);

  mm->addr += len;
  mm->len -= len;

  return 0;
}

static int unmapSuffix(struct proc *p, MappedMem *mm, uint64 addr) {
  for (uint64 va = addr; va < mm->addr + mm->len; va += PGSIZE) {
    if (unmapPage(p, mm, va) == -1) return -1;
  }
 
  uvmunmap(p->pagetable, addr, (mm->len - addr) / PGSIZE, 1);

  mm->len = addr - mm->addr;

  return 0;
}

int munmap(uint64 addr, size_t len) {
  if (addr % PGSIZE) {
    return -1;
  }

  if (len % PGSIZE) {
    return -1;
  }

  struct proc *p = myproc();
  MappedMem *mm = getMappedMem(p, addr);
  if (mm == 0) {
    return -1;
  }

  if (addr == mm->addr) {
    if (unmapPrefix(p, mm, len) == -1) return -1;
  } else if (addr + len == mm->addr + mm->len) {
    if (unmapSuffix(p, mm, addr) == -1) return -1;
  } else {
    return -1;
  }

  if (mm->len == 0) {
    fileclose(mm->file);
    
    mm->file = 0;
    mm->addr = 0;
    mm->orgAddr = 0;
    mm->len = 0;
  }

  return 0;
}

