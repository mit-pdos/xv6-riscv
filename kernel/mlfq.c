#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "mlfq.h"

// External reference to proc array from proc.c
extern struct proc proc[NPROC];

// Global aging timer
uint64 last_aging_time = 0;

// External reference to base time quantum array from proc.c
extern const uint64 base_time_quantum[NPRIO];

// Allotment limits (in ticks) - maximum time allowed at each priority level
static const uint64 max_allotment[NPRIO] = {
  MAX_ALLOTMENT_0,
  MAX_ALLOTMENT_1,
  MAX_ALLOTMENT_2,
  MAX_ALLOTMENT_3
};

// Check and enforce allotment limits
void
check_allotment(struct proc *p)
{
  if(p->state == UNUSED || p->state == ZOMBIE)
    return;
    
  p->allotment[p->priority]++;

  if(p->allotment[p->priority] >= max_allotment[p->priority]) {
    // Allotment exhausted - demote
    if(p->priority < NPRIO - 1) {
      p->priority++;
      p->time_slice_remaining = base_time_quantum[p->priority];
    }
  }
}

// Reset allotments during aging
void
reset_allotments(struct proc *p)
{
  for(int i = 0; i < NPRIO; i++) {
    p->allotment[i] = 0;
  }
}

// MLFQ aging function - boosts all processes to prevent starvation
void
mlfq_aging(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);

    if(p->state != UNUSED && p->priority > 0) {
      // Boost priority to highest level
      p->priority = 0;

      // Reset time slice to highest priority quantum
      p->time_slice_remaining = base_time_quantum[0];

      // Update boost timestamp
      p->priority_boost_time = ticks;

      // Reset allotments for fresh start
      reset_allotments(p);
    }

    release(&p->lock);
  }
}

// Initialize aging system
void
mlfq_aging_init(void)
{
  last_aging_time = ticks;
}
