#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "riscv.h"

struct run {
    struct run *next;
  };
  
 extern struct {
    struct spinlock lock;
    struct run *freelist;
  } kmem;


  static int 
  countfreepages(void)
  {
    int count = 0;
    struct run *r;

    acquire(&kmem.lock);

    for(r = kmem.freelist; r!=0; r = r->next){
        count++;
    }
    release(&kmem.lock);
    
    return count;
  }

  uint64
  sys_freemem(void)
  {
    int pages = countfreepages();
    return (uint64)(pages * PGSIZE); 
  }