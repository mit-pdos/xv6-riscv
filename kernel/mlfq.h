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

// Allotment limits (in ticks) - maximum time allowed at each priority level
#define MAX_ALLOTMENT_0    100    // Priority 0 (highest)
#define MAX_ALLOTMENT_1    200    // Priority 1
#define MAX_ALLOTMENT_2    400    // Priority 2
#define MAX_ALLOTMENT_3    800    // Priority 3 (lowest)

#endif
