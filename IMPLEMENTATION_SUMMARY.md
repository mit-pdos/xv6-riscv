# CPU Usage Tracking with Exponential Moving Average and Aging Implementation

## Overview
This implementation adds CPU usage tracking using exponential moving average (EMA) for behavior classification and periodic priority boost to prevent starvation in XV6 kernel. The system tracks process CPU usage, classifies processes as CPU-bound or I/O-bound for scheduling decisions, and implements aging to ensure fair scheduling.

## Files Modified

### 1. kernel/mlfq.h (NEW)
- Defines MLFQ configuration constants
- ALPHA = 0.3f (smoothing factor for EMA)
- NPRIO = 4 (number of priority levels)
- Time quantum per priority level
- CPU usage thresholds for behavior classification
- AGING_INTERVAL = 100 (configurable aging interval)

### 2. kernel/mlfq.c (NEW)
- Implements MLFQ aging functions
- `mlfq_aging()` - boosts all processes to priority 0
- `mlfq_aging_init()` - initializes aging timer
- Global aging timer management

### 3. kernel/proc.h
- Added `#include "mlfq.h"`
- Added MLFQ tracking fields to proc structure:
  - `int priority` - Current priority level (0 = highest)
  - `uint64 time_slice_remaining` - Remaining time in current quantum
  - `float cpu_usage_avg` - Exponential moving average of CPU usage
  - `uint64 priority_boost_time` - Time of last priority boost

### 4. kernel/proc.c
- Made `base_time_quantum` non-static for external access
- Enhanced `allocproc()` to initialize MLFQ fields including `priority_boost_time`
- Implemented `update_cpu_usage()` function with EMA formula
- Implemented `handle_quantum_expiration()` function for behavior classification
- Modified `yield()` function to track quantum usage
- Enhanced `procdump()` to display priority and CPU usage

### 5. kernel/trap.c
- Added `#include "mlfq.h"`
- Added external reference to `last_aging_time`
- Modified `clockintr()` to check aging interval and call `mlfq_aging()`

### 6. kernel/main.c
- Added `mlfq_aging_init()` call to initialize aging system

### 7. kernel/defs.h
- Added function declarations for CPU usage tracking and aging functions

### 8. Makefile
- Added mlfq.c to OBJS list
- Added test programs: cpubound, iobound, agingtest

### 9. User Test Programs
- `user/cpubound.c` - CPU-intensive workload (prime number calculation)
- `user/iobound.c` - I/O-intensive workload (repeated pause calls)
- `user/agingtest.c` - Multi-process aging test with long CPU-bound tasks

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

### mlfq_aging(void)
```c
void mlfq_aging(void)
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
    }

    release(&p->lock);
  }
}
```

## Behavior Classification

- **CPU-bound processes**: cpu_usage_avg > QUANTUM_THRESHOLD_HIGH (5.0)
  - Demoted to lower priority levels
  - Get longer time quanta but lower scheduling priority
  
- **I/O-bound processes**: cpu_usage_avg < QUANTUM_THRESHOLD_LOW (2.0)
  - Promoted to higher priority levels
  - Get shorter time quanta but higher scheduling priority

## Aging System

- **Aging Interval**: 100 ticks (configurable via AGING_INTERVAL)
- **Priority Boost**: All processes boosted to priority 0 every interval
- **Starvation Prevention**: Ensures no process remains at low priority indefinitely
- **Minimal Overhead**: Aging operation runs efficiently during timer interrupts

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
5. **Aging timer**: Every AGING_INTERVAL ticks, all processes are boosted to priority 0

## Testing

The implementation includes three test programs:
- `cpubound`: Calculates prime numbers to generate consistent CPU usage
- `iobound`: Uses pause() calls to simulate I/O waiting behavior
- `agingtest`: Creates multiple CPU-bound processes to test aging functionality

## Verification

Use Ctrl+P in the emulator to view process statistics including:
- Process ID and state
- Priority level
- CPU usage average (EMA value)
- Priority boost timestamp

The system successfully:
- Tracks CPU usage using EMA
- Classifies process behavior
- Adjusts scheduling priorities accordingly
- Prevents starvation through periodic priority boosts
- Maintains minimal performance impact
