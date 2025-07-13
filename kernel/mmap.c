#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"

// virtual address of the i-th mmap page
#define MMAPADDR(i) (TRAPFRAME - PGSIZE - ((uint64)(i)) * PGSIZE)

// index of mmap page given by the virtual address
#define MMAPPAGE(a) ((TRAPFRAME - ((uint64)(a)) - 1) / PGSIZE)

// allocate mmap pages for a process
// returns the address of the first page allocated, or ((void *) -1) on failure
uint64
mmapalloc(struct proc *p, uint64 addr, size_t length)
{
  uint64 npages = PGROUNDUP(length) / PGSIZE; 
  size_t i, j; 

  if((addr % PGSIZE) != 0)
    panic("mmapalloc: not aligned");

  for(i = 0; i < MMAPPAGES;){
    for(j = 0; i + j < MMAPPAGES && j < npages; j++){
      if((p->bmap[(i + j) / 8] & (1 << ((i + j) % 8))) != 0)
        break; // this page is already allocated
    }
    if(j == npages){
      for(j = 0; j < npages; j++)
        p->bmap[(i + j) / 8] |= (1 << ((i + j) % 8)); // mark pages as allocated
      return MMAPADDR(i+j-1);  
    } 
    i += j + 1; 
  }
  return -1; 
}

// free mmap pages for a process
void
mmapfree(struct proc *p, uint64 addr, size_t length)
{
  uint64 npages = PGROUNDUP(length) / PGSIZE; 
  size_t start = MMAPPAGE(addr), end = start + npages, i; 

  if((addr % PGSIZE) != 0)
    panic("mmapfree: not aligned");

  if(addr < MMAPADDR(MMAPPAGES-1) || addr + length > TRAPFRAME)
    panic("mmapfree: out of bounds");

  for(i = start; i <= end; i++)
    p->bmap[i / 8] &= ~(1 << (i % 8)); // mark page as free 
}

uint64
do_mmap(struct proc *p, uint64 addr, size_t length, int prot, int flags, 
        struct file *f, off_t offset)
{
  struct vma *vma; 

  // only map inode or device files
  if(f->type != FD_INODE && f->type != FD_DEVICE)
    return -1;

  // addr and offset must be page-aligned
  if((addr % PGSIZE) != 0 || (offset % PGSIZE) != 0)
    return -1; 

  // file must be writable if PROT_WRITE and MAP_SHARED are set 
  if((prot & PROT_WRITE) && (flags & MAP_SHARED) && f->writable == 0)
    return -1;

  for(vma = p->vma; vma < p->vma + NVMA; vma++){
    if(vma->addr == 0)
      break;  
  }
  if(vma >= p->vma + NVMA)
    return -1; 
  
  if((vma->addr = mmapalloc(p, addr, length)) == ((uint64) -1))
    return -1; 
  vma->length = length; 
  vma->prot = prot; 
  vma->flags = flags; 
  vma->offset = offset; 
  vma->file = filedup(f); 
  ilock(f->ip); 
  vma->isize = f->ip->size; 
  iunlock(f->ip); 
  return vma->addr; 
}

int
do_munmap(struct proc *p, uint64 addr, size_t length)
{
  uint64 a, npages; 
  off_t off;  
  struct vma *vma; 
  int n, ret = 0; 

  if((addr % PGSIZE) != 0)
    return -1; 
  
  for(vma = p->vma; vma < p->vma + NVMA; vma++){
    if(vma->length > 0 && vma->addr <= addr && 
        addr + length <= vma->addr + vma->length)
      break; 
  }
  if(vma >= p->vma + NVMA)
    return -1; 

  // free vma memory and write back to file if MAP_SHARED
  off = vma->offset + (off_t)(addr - vma->addr);
  for(a = addr; a < addr + length; a += PGSIZE){
    if(walkaddr(p->pagetable, a) != 0){
      if((vma->prot & PROT_WRITE) && (vma->flags & MAP_SHARED) && off < vma->isize){
        n = off + PGSIZE <= vma->isize ? PGSIZE : vma->isize - off; 
        if(filewrite_at(vma->file, a, off, n) < 0)
          ret = -1; 
      }
      uvmunmap(p->pagetable, a, 1, 1); 
    }
    off += PGSIZE; 
  }
  mmapfree(p, addr, length); 

  // resize vma, assume no hole punching
  npages = PGROUNDUP(length) / PGSIZE; 
  if(vma->addr == addr){
    vma->addr += npages * PGSIZE; 
    vma->offset += npages * PGSIZE;
  }
  if(vma->length >= npages * PGSIZE)
    vma->length -= npages * PGSIZE; 
  else
    vma->length = 0; 
  if(vma->length == 0){
    // free the vma, if length is zero
    fileclose(vma->file);  
    memset(vma, 0, sizeof(*vma)); 
  }
  return ret; 
}

int
vmacopy(struct proc *old, struct proc *new)
{
  pte_t *pte; 
  uint64 pa, a; 
  uint flags; 
  char *mem; 
  int i; 
  
  for(i = 0; i < NVMA; i++){
    if(old->vma[i].addr != 0){
      new->vma[i].addr = old->vma[i].addr;
      new->vma[i].length = old->vma[i].length;
      new->vma[i].prot = old->vma[i].prot;
      new->vma[i].flags = old->vma[i].flags;
      new->vma[i].offset = old->vma[i].offset;
      new->vma[i].file = filedup(old->vma[i].file);
      new->vma[i].isize = old->vma[i].isize;

      for(a = old->vma[i].addr; a < old->vma[i].addr + old->vma[i].length; a += PGSIZE){
        if((pte = walk(old->pagetable, a, 0)) != 0 && (*pte & PTE_V) != 0){
          pa = PTE2PA(*pte); 
          flags = PTE_FLAGS(*pte);
          // TODO: handle shared mappings
          if((mem = kalloc()) == 0)
            goto err;
          memmove(mem, (char*)pa, PGSIZE);
          if(mappages(new->pagetable, a, PGSIZE, (uint64)mem, flags) != 0){
            kfree(mem);
            goto err;
          }
        }
      }
    }
  }
  return 0; 

  err:
    for(i = 0; i < NVMA; i++){
      if(new->vma[i].addr != 0){
        for(a = old->vma[i].addr; a < old->vma[i].addr + old->vma[i].length; a += PGSIZE){
          if((pte = walk(new->pagetable, a, 0)) != 0 && (*pte & PTE_V) != 0)
            uvmunmap(new->pagetable, a, 1, 1); 
        }
        fileclose(new->vma[i].file); 
        memset(&new->vma[i], 0, sizeof(struct vma)); 
      }
    }
    return -1;
}