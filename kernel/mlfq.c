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

      // Note: In a full MLFQ implementation, we would remove from current queue
      // and re-queue at new priority, but since we're using a simple scheduler,
      // the priority field alone is sufficient for scheduling decisions
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
