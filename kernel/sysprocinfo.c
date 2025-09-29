#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

extern struct proc proc[NPROC];  // Array of processes

// Get process information for a specific process
uint64
sys_getprocinfo(void)
{
  int pid;
  uint64 info_ptr;
  
  // Get arguments from user space
  argint(0, &pid);       // Get the pid argument
  argaddr(1, &info_ptr); // Get the pointer to user struct
  
  // Local struct to store info before copying to user space
  struct {
    int pid;
    int state;
    uint64 sz;
    uint64 kstack;
    char name[16];
  } info;
  
  struct proc *p;
  int found = 0;
  
  // Lock required when accessing process table
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->pid == pid) {
      // Copy the process information to our local struct
      info.pid = p->pid;
      info.state = p->state;
      info.sz = p->sz;
      info.kstack = p->kstack;
      strncpy(info.name, p->name, sizeof(info.name));
      
      found = 1;
      release(&p->lock);
      break;
    }
    release(&p->lock);
  }
  
  if(found) {
    // Copy the info to user space
    if(copyout(myproc()->pagetable, info_ptr, (char*)&info, sizeof(info)) < 0)
      return -1;
    return 0;
  } else {
    return -1; // Process not found
  }
}