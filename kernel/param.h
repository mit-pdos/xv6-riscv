// Scheduler type constants — passed via -DSCHED_TYPE=N at compile time.
#define SCHED_RR      0   // Simple round-robin
#define SCHED_MLFQ    1   // MLFQ with fixed time quanta
#define SCHED_MLFQ_AQ 2   // MLFQ with adaptive (load-adjusted) time quanta
#ifndef SCHED_TYPE
#define SCHED_TYPE SCHED_MLFQ_AQ  // default when not specified
#endif

#define RR_QUANTUM    10   // Fixed time slice for round-robin (ticks)

#define MLFQ_LEVELS        5   // number of MLFQ priority levels (0 = highest)
#define MLFQ_IO_WAKE_BOOST 2   // promote by this many levels on sleep wakeup (0 = off)
// Global MLFQ aging: periodic priority boost every N timer ticks (0 = disabled).
// Override at compile time: -DMLFQ_AGING_INTERVAL=500
#ifndef MLFQ_AGING_INTERVAL
#define MLFQ_AGING_INTERVAL 50
#endif

#define NPROC        64  // maximum number of processes
#define NCPU          8  // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       100  // open files per system
#define NINODE       50  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  10  // max # of blocks any FS op writes
#define LOGBLOCKS    (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define FSSIZE       2000  // size of file system in blocks
#define MAXPATH      128   // maximum file path name
#define USERSTACK    4     // user stack pages (increased from 1 to prevent overflow)


