// Multi-Level Feedback Queue (MLFQ) scheduler configuration and data structures.
// This header defines priority levels, time quanta, aging behavior, and
// per-queue metadata used by the scheduler.

#ifndef MLFQ_H
#define MLFQ_H

#include "types.h"
#include "spinlock.h"

// Forward declaration to avoid circular dependencies with proc.h.
struct proc;

// **Configuration macros**
// Set to 1 to enable the MLFQ scheduler code paths.
#define MLFQ_ENABLED            1
// Enable priority aging to gradually boost long-waiting processes.
#define MLFQ_AGING_ENABLED      1
// Enable dynamic adjustments based on observed CPU/I/O behavior.
#define MLFQ_BEHAVIOR_TRACKING  1

// **Core constants**
// NPRIO: Number of priority levels in the MLFQ (0 = highest priority).
#define NPRIO 8

// AGING_INTERVAL: Number of ticks after which a process that has been waiting
// in a lower-priority queue is considered for a priority boost.
#define AGING_INTERVAL 1000

// QUANTUM_THRESHOLD_LOW: Percentage of allotted time quantum below which a
// process is considered I/O-bound (tends to yield or block early).
#define QUANTUM_THRESHOLD_LOW 50

// QUANTUM_THRESHOLD_HIGH: Percentage of allotted time quantum above which a
// process is considered CPU-bound (tends to run for almost the full quantum).
#define QUANTUM_THRESHOLD_HIGH 90

// ALPHA: Exponential moving average (EMA) smoothing factor used when tracking
// recent CPU usage / quantum consumption. Range \[0,1\].
#define ALPHA 0.3

// Priority level base time quanta (in ticks) for each priority level.
// Index 0 is the highest priority with the smallest quantum; lower priority
// levels receive progressively larger quanta.
static const uint64 base_time_quantum[NPRIO] = {
  5,   // Level 0 (highest priority)
  10,  // Level 1
  20,  // Level 2
  40,  // Level 3
  80,  // Level 4
  160, // Level 5
  240, // Level 6
  320  // Level 7 (lowest priority)
};

// Per-priority MLFQ run queue metadata.
struct mlfq_queue {
  struct proc *head;        // Head of the run queue (FIFO).
  struct proc *tail;        // Tail of the run queue (FIFO).
  int size;                 // Number of runnable processes in this queue.
  uint64 time_quantum;      // Current time quantum (in ticks) for this level.
  struct spinlock lock;     // Lock protecting this queue.
};

#endif // MLFQ_H

