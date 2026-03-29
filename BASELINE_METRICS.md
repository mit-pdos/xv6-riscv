# Baseline Metrics Documentation

## System Configuration

**Test Environment**:
- Host OS: macOS
- Emulator: QEMU (xv6-riscv)
- Architecture: RISC-V 64-bit
- CPU Count: 3 (NCPU=3)
- Max Processes: 64 (NPROC=64)

---

## Baseline Metrics (Reference Values)

### System Performance Baseline

#### Boot Metrics
| Metric | Expected Value | Unit | Notes |
|--------|---|---|---|
| Boot Time | < 1000 | ticks | Time from start to first process ready |
| Initial Process Count | 1 | count | Only `init` process |
| Time to Init Fork | 50-200 | ticks | Time for init to fork shell |
| Time to Shell Ready | 100-300 | ticks | Time shell becomes interactive |

#### Single Process Baseline (Simple Commands)
| Metric | Expected Value | Unit | Notes |
|--------|---|---|---|
| User Program Load Time | 10-50 | ticks | Time from exec to first instruction |
| Simple Echo Command Duration | 50-150 | ticks | `echo hello` execution |
| Context Switches (per command) | 2-10 | count | System calls trigger context switches |
| Response Time | 5-20 | ticks | Time from ready to first run |
| CPU Utilization (single process) | 80-100 | % | Should be high for compute-bound |

#### Multi-Process Baseline
| Metric | Expected Value | Unit | Notes |
|--------|--------|---|---|
| Process Creation Time | 20-100 | ticks | Time for fork() syscall |
| Context Switches/Second | 50-500 | count/sec | Varies with workload |
| CPU Utilization (2-3 processes) | 90-100 | % | Most time spent in user code |
| Throughput (interactive shell) | 1-3 | cmds/sec | Commands per second |

#### Per-Process Baseline
| Metric | Expected Value | Unit | Notes |
|--------|---|---|---|
| Average Response Time | 5-30 | ticks | Time to first scheduling |
| Average Waiting Time | 10-50 | ticks | Time between context switches |
| Turnaround Time (simple cmd) | 50-200 | ticks | Total creation to completion |
| Context Switches (simple cmd) | 3-15 | count | Includes system calls |

### Scheduler Performance Baseline

#### Round-Robin Scheduling (RR)
| Metric | Expected Value | Unit | Notes |
|--------|---|---|---|
| Time Slice (quantum) | N/A | ticks | 1 timer interrupt = 1 tick |
| Context Switch Overhead | < 5 | ticks | Time to save/restore context |
| Fairness (equal load) | ± 10% | variance | Response time variance |
| Starvation (with I/O) | None | - | All processes eventually run |

#### I/O and Sleeping
| Metric | Expected Value | Unit | Notes |
|--------|---|---|---|
| Sleep/Wake Latency | 1-5 | ticks | Time from wakeup call to running |
| Blocked Process Overhead | ~0 | % | Sleeping processes consume no CPU |

---

## Metric Collection Methodology

### Timer Tick Conversion
- **Ticker Rate**: ~10 million ticks/second (QEMU simulation)
- **Conversion**: `milliseconds = ticks / 10000`

### Data Collection Points

1. **Process Creation** (`allocproc()`)
   - Record: creation_time = current_ticks
   
2. **First Run** (`scheduler()`)
   - Record: first_run_time = current_ticks
   - Calculate: response_time = first_run_time - creation_time
   
3. **Context Switch** (`yield()`)
   - Record: context_switches++
   - Calculate: time_since_last_run = current_ticks - last_run_time
   
4. **Process Exit** (transition to ZOMBIE)
   - Record: finish_time = current_ticks
   - Calculate: turnaround_time = finish_time - creation_time

---

## Expected Behavior Patterns

### CPU-Bound Process Pattern
```
Creation -> Wait (5-10 ticks) -> First Run -> 
  Execute without switching -> Exit
  
Metrics:
- Response Time: LOW (5-10 ticks)
- Context Switches: LOW (1-2)
- Turnaround Time: LOW (runtime + first wait)
```

### I/O-Bound Process Pattern
```
Creation -> Wait -> First Run -> System Call (print/read) ->
  Block/Sleep -> Wake -> Context Switch -> Resume ->
  More System Calls -> Exit
  
Metrics:
- Response Time: LOW (gets CPU quickly)
- Context Switches: HIGH (many I/O operations)
- Waiting Time: HIGH (blocked on I/O)
- Turnaround Time: Variable (depends on I/O)
```

### Mixed Workload Pattern
```
Multiple processes competing for CPU:
- Some sleeping on I/O
- Some ready to run
- Context switches: 5-20/second
- CPU Utilization: 95-100%
```

---

## Baseline Test Cases

### Test 1: Single User Process
```bash
Command: echo "Hello World"
Expected Metrics:
  - Response Time: 10-20 ticks
  - Context Switches: 5-10
  - Turnaround Time: 100-200 ticks
```

### Test 2: Fork and Wait
```bash
Command: forktest
Expected Metrics:
  - Multiple processes created
  - Context Switches: 100+ (many parent-child switches)
  - All processes complete successfully
```

### Test 3: Interactive Shell
```bash
Commands: Multiple commands in sequence
Expected Metrics:
  - Throughput: 2-5 commands/second
  - Response Time per command: 10-30 ticks
  - Context Switches: 5-15 per command
```

### Test 4: Concurrent Processes
```bash
Command: Multiple processes running simultaneously
Expected Metrics:
  - CPU Utilization: 95-100%
  - Context Switches/sec: 50-200
  - Fair time distribution among processes
```

---

## Metric Interpretation Guide

### Response Time (ticks)
- **< 10**: Excellent - Process scheduled immediately
- **10-30**: Good - Normal interactive response
- **30-100**: Acceptable - Some contention
- **> 100**: Poor - High system load

### Turnaround Time (ticks)
- **< 100**: Very fast execution (minimal I/O)
- **100-500**: Normal execution
- **> 500**: Slow (heavy I/O or many context switches)

### Context Switches
- **1-3**: CPU-bound process (good)
- **5-15**: Normal process with I/O
- **> 50**: Very interactive or I/O-heavy

### CPU Utilization (%)
- **< 50%**: Light load, scheduler idle time
- **50-80%**: Normal load
- **80-100%**: Full system capacity

### Throughput (commands/sec)
- **> 5**: Light load
- **2-5**: Typical interactive load
- **< 2**: Heavy load or slow commands

---

## Version History

| Date | Baseline Version | Changes | Notes |
|------|---|---|---|
| 2026-03-20 | 1.0 | Initial baseline | Standard xv6-riscv configuration |

---

## Notes

- All baselines assume standard xv6-riscv configuration
- Times are measured in system ticks (resolution: 100 nanoseconds each)
- Actual values may vary by ±20% depending on QEMU simulation speed
- Use these baselines to detect performance regressions
- Compare new metrics against these values to identify anomalies
