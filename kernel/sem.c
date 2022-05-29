#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "stat.h"
#include "proc.h"
#include "sem.h"

struct sem sem[NSEM];

int is_valid_sid(int sid);

void
seminit()
{
  struct sem *s;
  for(s = sem; s < sem + NSEM; s++){
    initlock(&s->lock, "semlock");
    s->key = -1;
  }
}

int 
semget(int key, int init_value)
{
  struct sem *s;
  struct sem *save_free = 0;
  

  int sid = get_sid();
  if(sid == -1){
    return -1;
  }

  //Searching the key in all semaphores
  for(s = sem; s < sem + NSEM; s++){
    acquire(&s->lock);
    // If the key was found, then jump to found: to update the ref count
    if(s->key == key){
      goto found;
    }
    // Save the first free one
    if(s->ref_count == 0 && save_free == 0){
      save_free = s;
    }
    else{
      release(&s->lock);
    }
  }

  // If the loop ends, then the key wasn't found,
  // so if it was saved then there's an unused semaphore and an empty place in osem,
  // so reinit and save to osem.
  if(save_free != 0 ){
    save_free->key = key;
    save_free->value = init_value;
    save_free->ref_count = 1;
    // Add the sempaphore in osem
    myproc()->osem[sid] = save_free;
  }
  release(&save_free->lock);
  return sid;
  
  // The key was found
  found:

    // If the semaphore with the key was found, and one semaphore was saved, then free it.
    if(save_free != 0){
      release(&save_free->lock);
    }

    // Increment the ref count in the semaphore
    s->ref_count++;

    // If there's an empty position then add the semaphore to the process' semaphore table
    myproc()->osem[sid] = s;
    release(&s->lock);
    return sid;
}

int 
semclose(int sid)
{
  if(!is_valid_sid(sid)){
    return -1;
  }
  acquire(&(myproc()->osem[sid]->lock));
  myproc()->osem[sid]->ref_count--;
  release(&(myproc()->osem[sid]->lock));
  myproc()->osem[sid] = 0;
  return 0;
}

int
semdown(int sid)
{
  if(!is_valid_sid(sid)){
    return -1;
  }
  acquire(&(myproc()->osem[sid]->lock));
  if(myproc()->osem[sid]->value >= 1){
    myproc()->osem[sid]->value--;
    release(&(myproc()->osem[sid]->lock));
    return 0;
  }
  release(&(myproc()->osem[sid]->lock));
  return -1;
}

int
semup(int sid)
{
  if(!is_valid_sid(sid)){
    return -1;
  }
  acquire(&(myproc()->osem[sid]->lock));
  myproc()->osem[sid]->value++;
  release(&(myproc()->osem[sid]->lock));
  return 0;
}

int
is_valid_sid(int sid){
  return sid >= 0 && sid <= NOSEM && myproc()->osem[sid];
}

// Increment ref count for e f.
struct sem*
semdup(struct sem *s)
{
  acquire(&s->lock);
  if(s->ref_count < 1)
    panic("semdup");
  s->ref_count++;
  release(&s->lock);
  return s;
}
