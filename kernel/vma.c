#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "proc.h"
#include "fs.h"
#include "buf.h"
#include "file.h"
#include "fcntl.h"
#include "stat.h"

#define min(a, b) ((a) < (b) ? (a) : (b))

// Allocate a vma region.
// Returns the allocated vma region on success, otherwise 0.
struct vma*
vmaalloc(struct vma *vmastart, uint64 addr, size_t length, int prot, int flags, 
         struct inode *ip, off_t offset)
{
  struct vma *vma;  

  if((addr % PGSIZE) != 0 || (offset % PGSIZE) != 0)
    panic("vmaalloc: not aligned");

  for(vma = vmastart; vma < vmastart + NVMA; vma++){
    if(!vma->valid){
      vma->addr = addr; 
      vma->length = length; 
      vma->prot = prot; 
      vma->flags = flags; 
      vma->ip = idup(ip); 
      vma->offset = offset; 
      vma->valid = 1; 
      return vma; 
    }
  }
  return 0; 
}

// Get the vma region associated with memory region.
// Returns the vma region if it exists, otherwise 0.
struct vma*
vmaget(struct vma *vmastart, uint64 addr, size_t length)
{
  struct vma *vma;

  for(vma = vmastart; vma < vmastart + NVMA; vma++){
    if(vma->valid && vma->addr <= addr && addr + length <= vma->addr + vma->length)
      return vma; 
  }
  return 0; 
}

// Read virtual address in vma into memory.
// Returns the physical address.
void *
vmaread(struct vma *vmastart, uint64 addr)
{
  uint64 pa; 
  off_t off; 
  struct vma *vma; 
  struct buf *bp; 
  int n; 

  if((vma = vmaget(vmastart, addr, 1)) == 0)
    return 0; 

  off = vma->offset + (off_t)(PGROUNDDOWN(addr) - vma->addr);

  if(vma->ip->type == T_DEVICE){
    if((pa = (uint64)kalloc()) == 0)
      return 0;
    memset((void *)pa, 0, PGSIZE); // zero page, in case of partial read
    if(vma->ip->major < 0 || vma->ip->major >= NDEV || !devsw[vma->ip->major].read){
      kfree((void *)pa); 
      return 0; 
    }
    n = min(PGSIZE, (vma->offset + vma->length) - off);
    if(devsw[vma->ip->major].read(0, pa, off, n) < 0){
      kfree((void *)pa);
      return 0;   
    }
    return (void *)pa; 
  } else if(vma->ip->type == T_FILE){
    if(vma->flags & MAP_SHARED){
      begin_op();  
      ilock(vma->ip); 
      uint a = bmap(vma->ip, off/BSIZE);  
      if(a == 0){
        iunlock(vma->ip); 
        end_op(); 
        return 0;
      }
      bp = bread(vma->ip->dev, a); 
      bpin(bp); // pin buffer to prevent eviction 
      brelse(bp);   
      iunlock(vma->ip); 
      end_op(); 
      return bp->data; 
    } else if(vma->flags & MAP_PRIVATE){
      if((pa = (uint64)kalloc()) == 0)
        return 0;
      memset((void *)pa, 0, PGSIZE); // zero page, in case of partial read
      begin_op(); 
      ilock(vma->ip); 
      n = min(BSIZE, vma->ip->size - off); 
      if(readi(vma->ip, 0, pa, off, n) != n){
        iunlock(vma->ip); 
        end_op(); 
        kfree((void *)pa); 
        return 0;
      }
      iunlock(vma->ip);  
      end_op(); 
      return (void *)pa; 
    }
  }
  return 0; 
}

// Releases virtual address in vma from memory.
// Physical address must be read from vmaread.
// Returns 0 on success and -1 on failure.
int
vmarelse(struct vma *vmastart, uint64 addr, uint64 pa)
{
  off_t off; 
  struct vma *vma; 
  struct buf *bp; 
  int n; 

  if((vma = vmaget(vmastart, addr, 1)) == 0)
    return -1; 

  off = vma->offset + (off_t)(PGROUNDDOWN(addr) - vma->addr);

  if(vma->ip->type == T_DEVICE){
    if(vma->flags & MAP_SHARED){
      int ret = 0; 
      if(vma->prot & PROT_WRITE){
        if(vma->ip->major < 0 || vma->ip->major >= NDEV || !devsw[vma->ip->major].write)
          ret = -1; 
        n = min(PGSIZE, (vma->offset + vma->length) - off); 
        if(devsw[vma->ip->major].write(0, pa, off, n) < 0)
          ret = -1; 
      }
      kfree((void *)pa); 
      return ret;  
    } else if(vma->flags & MAP_PRIVATE){
      kfree((void *)pa); 
      return 0; 
    }
  } else if(vma->ip->type == T_FILE){
    if(vma->flags & MAP_SHARED){
      begin_op(); 
      ilock(vma->ip); 
      uint a = bmap(vma->ip, off/BSIZE); 
      if(a == 0){
        iunlock(vma->ip); 
        end_op(); 
        return -1; 
      }
      bp = bread(vma->ip->dev, a); 
      n = min(BSIZE, vma->ip->size - off); 
      memset(bp->data + n, 0, BSIZE - n); // zero out overflow
      if(vma->prot & PROT_WRITE)
        log_write(bp); 
      bunpin(bp); // unpin buffer so it can be written to disk  
      brelse(bp); 
      iunlock(vma->ip); 
      end_op(); 
      return 0;
    } else if(vma->flags & MAP_PRIVATE){
      kfree((void *)pa);
      return 0;
    }
  }
  return -1;  
}

// Free memory region from vma regions.
void
vmafree(struct vma *vmastart, uint64 addr, size_t length)
{
  uint64 a, end, npages;  
  struct vma *vma;

  if((addr % PGSIZE) != 0)
    panic("vmafree: not aligned");

  for(a = addr; a < addr + length;){
    if((vma = vmaget(vmastart, a, 1)) != 0){
      end = min(vma->addr + vma->length, addr + length); 
      npages = PGROUNDUP(end - a) / PGSIZE; 
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
        begin_op(); 
        ilock(vma->ip);  
        iupdate(vma->ip); // inode blocks may have been allocated 
        iunlockput(vma->ip); 
        end_op(); 
        vma->valid = 0; 
      }
      a += npages * PGSIZE; 
    } else {
      a += PGSIZE;
    }
  }
}
