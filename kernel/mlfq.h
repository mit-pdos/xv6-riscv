#ifndef MLFQ_H
#define MLFQ_H

// MLFQ configuration constants
#define NPRIO          4     // Number of priority levels
#define ALPHA          0.3f  // Smoothing factor for EMA

// Time quantum per priority level (in timer ticks)
#define BASE_QUANTUM_0    1   // Highest priority
#define BASE_QUANTUM_1    2
#define BASE_QUANTUM_2    4
#define BASE_QUANTUM_3    8   // Lowest priority

// CPU usage thresholds for behavior classification
#define QUANTUM_THRESHOLD_HIGH  5.0f  // CPU-bound threshold
#define QUANTUM_THRESHOLD_LOW   2.0f  // I/O-bound threshold

// Aging configuration
#define AGING_INTERVAL     100    // Aging interval in ticks (configurable)

#endif
