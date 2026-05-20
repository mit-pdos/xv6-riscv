// Mutual exclusion lock.
struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.
};

// "Inverted" logic ahead!
// This is done to get a tiny gain
// for a tighter spinlock loop
#define SPINLOCK_HELD 0
#define SPINLOCK_FREE 1
