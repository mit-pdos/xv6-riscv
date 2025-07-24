#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"
#include "stat.h"

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
  uint64 a;  

  // only map inode files and devices 
  if(f->type != FD_INODE && f->type != FD_DEVICE &&
     f->ip->type != T_FILE && f->ip->type != T_DEVICE)
    return -1;

  // addr and offset must be page-aligned
  if((addr % PGSIZE) != 0 || (offset % PGSIZE) != 0)
    return -1; 

  // file must be writable if PROT_WRITE and MAP_SHARED are set 
  if((prot & PROT_WRITE) && (flags & MAP_SHARED) && f->writable == 0)
    return -1;

  a = mmapalloc(p, addr, length); 
  vmaalloc(p, a, length, prot, flags, f->ip, offset);  
  return a; 
}

int
do_munmap(struct proc *p, uint64 addr, size_t length)
{
  struct vma *vma; 
  int ret; 

  // addr must be page-aligned
  if((addr % PGSIZE) != 0)
    return -1; 
  
  vma = vmaget(p, addr, length); 
  ret = proc_freevma(p, vma, addr, length); 
  mmapfree(p, addr, length); 
  return ret; 
}
