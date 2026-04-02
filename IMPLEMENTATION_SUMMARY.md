# CPU Usage Tracking with EMA, Aging, and Allotment Implementation

## Overview
This implementation adds comprehensive MLFQ (Multi-Level Feedback Queue) scheduling to XV6 kernel with CPU usage tracking using exponential moving average (EMA), behavior classification, periodic priority boost to prevent starvation, and allotment tracking to prevent gaming. The system tracks process CPU usage, classifies processes as CPU-bound or I/O-bound, prevents starvation through aging, and stops processes from gaming the scheduler through allotment enforcement.

## Files Modified

### 1. kernel/mlfq.h (NEW)
- Defines MLFQ configuration constants
- ALPHA = 0.3f (smoothing factor for EMA)
- NPRIO = 4 (number of priority levels)
- Time quantum per priority level
- CPU usage thresholds for behavior classification
- AGING_INTERVAL = 100 (configurable aging interval)
- Allotment limits per priority level (MAX_ALLOTMENT_0 through MAX_ALLOTMENT_3)

### 2. kernel/mlfq.c (NEW)
- Implements MLFQ aging and allotment functions
- `mlfq_aging()` - boosts all processes to priority 0
- `mlfq_aging_init()` - initializes aging timer
- `check_allotment()` - enforces allotment limits and demotes when exhausted
- `reset_allotments()` - resets allotments during aging
- Global aging timer and max_allotment array

### 3. kernel/proc.h
- Added `#include "mlfq.h"`
- Added MLFQ tracking fields to proc structure:
  - `int priority` - Current priority level (0 = highest)
  - `uint64 time_slice_remaining` - Remaining time in current quantum
  - `float cpu_usage_avg` - Exponential moving average of CPU usage
  - `uint64 priority_boost_time` - Time of last priority boost
  - `uint64 allotment[NPRIO]` - Time spent at each priority level

### 4. kernel/proc.c
- Made `base_time_quantum` non-static for external access
- Enhanced `allocproc()` to initialize MLFQ fields including `priority_boost_time` and `allotment` array
- Implemented `update_cpu_usage()` function with EMA formula
- Implemented `handle_quantum_expiration()` function for behavior classification
- Modified `yield()` function to track quantum usage and check allotment limits
- Enhanced `procdump()` to display priority, CPU usage, and current allotment

### 5. kernel/trap.c
- Added `#include "mlfq.h"`
- Added external reference to `last_aging_time`
- Modified `clockintr()` to check aging interval and call `mlfq_aging()`

### 6. kernel/main.c
- Added `mlfq_aging_init()` call to initialize aging system

### 7. kernel/defs.h
- Added function declarations for CPU usage tracking, aging, and allotment functions

### 8. Makefile
- Added mlfq.c to OBJS list
- Added test programs: cpubound, iobound, agingtest, gamingtest, legitimate_io

### 9. User Test Programs
- `user/cpubound.c` - CPU-intensive workload (prime number calculation)
- `user/iobound.c` - I/O-intensive workload (repeated pause calls)
- `user/agingtest.c` - Multi-process aging test with long CPU-bound tasks
- `user/gamingtest.c` - Attempts to game scheduler using voluntary yields
- `user/legitimate_io.c` - Legitimate I/O process that should maintain good priority

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

### check_allotment(struct proc *p)
```c
void check_allotment(struct proc *p)
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
```

### reset_allotments(struct proc *p)
```c
void reset_allotments(struct proc *p)
{
  for(int i = 0; i < NPRIO; i++) {
    p->allotment[i] = 0;
  }
}
```

## Allotment System

- **Allotment Limits**: Maximum time allowed at each priority level:
  - Priority 0: 100 ticks (highest priority - shortest allotment)
  - Priority 1: 200 ticks
  - Priority 2: 400 ticks  
  - Priority 3: 800 ticks (lowest priority - longest allotment)
- **Gaming Prevention**: Processes cannot stay at high priority indefinitely
- **Automatic Demotion**: When allotment exhausted, process is demoted to next priority
- **Reset on Aging**: All allotments reset during periodic aging boosts

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
3. **Allotment tracking**: `check_allotment()` called on each timer preemption
4. **Quantum expiration**: When time_slice_remaining reaches 0, behavior classification occurs
5. **Priority adjustment**: Process priority is adjusted based on CPU usage patterns and allotment limits
6. **Aging timer**: Every AGING_INTERVAL ticks, all processes are boosted to priority 0
7. **Allotment reset**: All allotments reset during aging to prevent starvation

## Testing

The implementation includes five test programs:
- `cpubound`: Calculates prime numbers to generate consistent CPU usage
- `iobound`: Uses pause() calls to simulate I/O waiting behavior
- `agingtest`: Creates multiple CPU-bound processes to test aging functionality
- `gamingtest`: Attempts to game scheduler using voluntary yields to test allotment enforcement
- `legitimate_io`: Legitimate I/O process that should maintain good priority without being penalized

## Verification

Use Ctrl+P in the emulator to view process statistics including:
- Process ID and state
- Priority level
- CPU usage average (EMA value)
- Current allotment usage at current priority level
- Priority boost timestamp

The system successfully:
- Tracks CPU usage using EMA
- Classifies process behavior
- Adjusts scheduling priorities accordingly
- Prevents starvation through periodic priority boosts
- Enforces allotment limits to prevent gaming
- Maintains minimal performance impact
- Protects legitimate I/O processes from unfair penalties
