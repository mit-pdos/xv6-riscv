# CPU Usage Tracking with Exponential Moving Average Implementation

## Overview
This implementation adds CPU usage tracking using exponential moving average (EMA) for behavior classification in the XV6 kernel. The system tracks process CPU usage and classifies processes as CPU-bound or I/O-bound for scheduling decisions.

## Files Modified

### 1. kernel/mlfq.h (NEW)
- Defines MLFQ configuration constants
- ALPHA = 0.3f (smoothing factor for EMA)
- NPRIO = 4 (number of priority levels)
- Time quantum per priority level
- CPU usage thresholds for behavior classification

### 2. kernel/proc.h
- Added `#include "mlfq.h"`
- Added MLFQ tracking fields to proc structure:
  - `int priority` - Current priority level (0 = highest)
  - `uint64 time_slice_remaining` - Remaining time in current quantum
  - `float cpu_usage_avg` - Exponential moving average of CPU usage

### 3. kernel/proc.c
- Added base time quantum array
- Enhanced `allocproc()` to initialize MLFQ fields
- Implemented `update_cpu_usage()` function with EMA formula
- Implemented `handle_quantum_expiration()` function for behavior classification
- Modified `yield()` function to track quantum usage
- Enhanced `procdump()` to display priority and CPU usage

### 4. kernel/defs.h
- Added function declarations for CPU usage tracking functions

### 5. Makefile
- Added test programs to build: cpubound and iobound

### 6. User Test Programs
- `user/cpubound.c` - CPU-intensive workload (prime number calculation)
- `user/iobound.c` - I/O-intensive workload (repeated pause calls)

## Key Functions

### update_cpu_usage(struct proc *p, uint64 time_used)
```c
void update_cpu_usage(struct proc *p, uint64 time_used)
{
  float alpha = ALPHA;  // 0.3 from mlfq.h

  // Exponential moving average
  p->cpu_usage_avg = alpha * (float)time_used +
                     (1.0 - alpha) * p->cpu_usage_avg;
}
```

### handle_quantum_expiration(struct proc *p)
```c
void handle_quantum_expiration(struct proc *p)
{
  uint64 time_used = base_time_quantum[p->priority] -
                     p->time_slice_remaining;

  update_cpu_usage(p, time_used);

  // Classify behavior based on average
  if(p->cpu_usage_avg > QUANTUM_THRESHOLD_HIGH) {
    // CPU-bound: demote more aggressively
    if(p->priority < NPRIO - 1) {
      p->priority++;
    }
  } else if(p->cpu_usage_avg < QUANTUM_THRESHOLD_LOW) {
    // I/O-bound: promote to higher priority
    if(p->priority > 0) {
      p->priority--;
    }
  }
  
  // Reset time slice for new quantum
  p->time_slice_remaining = base_time_quantum[p->priority];
}
```

## Behavior Classification

- **CPU-bound processes**: cpu_usage_avg > QUANTUM_THRESHOLD_HIGH (5.0)
  - Demoted to lower priority levels
  - Get longer time quanta but lower scheduling priority
  
- **I/O-bound processes**: cpu_usage_avg < QUANTUM_THRESHOLD_LOW (2.0)
  - Promoted to higher priority levels
  - Get shorter time quanta but higher scheduling priority

## EMA Formula

The exponential moving average is calculated as:
```
cpu_usage_avg = α * time_used + (1 - α) * previous_cpu_usage_avg
```

Where α = 0.3, providing a balance between responsiveness and stability.

## Integration Points

1. **Timer interrupts**: The `yield()` function is called during timer preemptions
2. **Quantum tracking**: Time slice is decremented on each timer interrupt
3. **Quantum expiration**: When time_slice_remaining reaches 0, behavior classification occurs
4. **Priority adjustment**: Process priority is adjusted based on CPU usage patterns

## Testing

The implementation includes two test programs:
- `cpubound`: Calculates prime numbers to generate consistent CPU usage
- `iobound`: Uses pause() calls to simulate I/O waiting behavior

## Verification

Use Ctrl+P in the emulator to view process statistics including:
- Process ID and state
- Priority level
- CPU usage average (EMA value)

The system successfully:
- Tracks CPU usage using EMA
- Classifies process behavior
- Adjusts scheduling priorities accordingly
- Maintains minimal performance impact
