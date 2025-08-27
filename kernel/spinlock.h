// Mutual exclusion lock.
struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.

};

#define NSEM 100 // System-wide limit of 100 semaphores
struct semaphore {
  struct spinlock lock;
  int count;
  int valid; // 0 if free, 1 if in use
};

