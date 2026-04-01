# Process Scheduling Metrics Implementation

## Overview
Three key scheduling metrics have been added to xv6-riscv to track process performance:

1. **Average Waiting Time** - Average time a process spends in the ready queue before getting CPU time
2. **Average Response Time** - Time from when a process is created until it first gets CPU time
3. **Context Switch Count** - Number of times a process has been switched off the CPU

## Implementation Details

### Data Structure Changes

**File: `kernel/proc.h`**

Added four new fields to `struct proc`:

```c
// Process scheduling metrics
uint creation_time;          // Time (in ticks) when process was created
uint first_run_time;         // Time (in ticks) when process first ran
uint total_wait_time;        // Total accumulated waiting time (in ticks)
uint context_switches;       // Number of times process has been context switched
```

### Implementation in proc.c

#### 1. Initialization (`allocproc()`)
When a process is allocated, the metrics are initialized:
- `creation_time` - Set to current tick count
- `first_run_time` - Set to 0 (will be updated on first scheduling)
- `total_wait_time` - Set to 0
- `context_switches` - Set to 0

#### 2. First Run Tracking (`scheduler()`)
When a process transitions from RUNNABLE to RUNNING for the first time:
- `first_run_time` is set to current tick count
- `total_wait_time` is calculated as: `first_run_time - creation_time`

#### 3. Context Switch Tracking (`yield()`)
When a process yields (transitions from RUNNING back to RUNNABLE):
- `context_switches` is incremented

### Helper Functions

Three accessor functions have been added to `proc.c` and exported in `defs.h`:

```c
// Get average waiting time in ticks
uint proc_avg_waiting_time(struct proc *p);

// Get response time in ticks (first run - creation)
uint proc_response_time(struct proc *p);

// Get context switch count
uint proc_context_switches(struct proc *p);

// Print all metrics for all processes
void proc_print_metrics(void);
```

## Usage

### From Kernel Code

To print all process scheduling metrics from kernel code (e.g., from main.c or a syscall):

```c
proc_print_metrics();
```

Output format:
```
Process Scheduling Metrics:
PID    Name            Avg Wait    Response    Context Switches
---    ----            --------    --------    -------- --------
1      init            0           5           2
2      sh              10          15          8
...
```

### From User Programs (via Syscalls)

To access metrics from user programs, you can:

1. Add syscall wrappers in `kernel/syscall.c`
2. Create user library functions in `user/ulib.c`
3. For example, create a syscall that returns metrics for a specific PID

Example syscall implementation pattern:
```c
// In kernel/syscall.c
uint64 sys_get_proc_metrics(void) {
  int pid;
  argint(0, &pid);
  struct proc *p = getproc(pid);  // lookup proc by pid
  
  // Return metrics (you might use a buffer for multiple values)
  return proc_avg_waiting_time(p);
}
```

## Metrics Explained

### Average Waiting Time
- **Definition**: Total time process spent waiting / (context_switches + 1)
- **Unit**: CPU ticks
- **Interpretation**: Lower is better - indicates the process quickly gets CPU access when needed

### Response Time  
- **Definition**: first_run_time - creation_time
- **Unit**: CPU ticks
- **Interpretation**: Time from process creation until first CPU access. Lower indicates responsive scheduling.

### Context Switch Count
- **Definition**: Number of times process transitioned from RUNNING → RUNNABLE
- **Unit**: Count
- **Interpretation**: Shows interactive processes have higher counts. I/O bound processes may have high counts. CPU-bound processes typically have fewer context switches.

## Time Unit
All metrics use xv6 timer ticks. The number of ticks per second depends on the hardware configuration (typically ~10 million ticks per second in QEMU simulation).

## Testing

The metrics are automatically collected for all processes. To verify:

1. Build the kernel: `make`
2. Run xv6: `make qemu`
3. Add a call to `proc_print_metrics()` in kernel functions like:
   - `main()` - Print on boot
   - `syscall.c` in a new `sys_metrics()` syscall
   - `console.c` in a debug command handler

## Notes

- Metrics are accurate only for the duration the process is alive
- Context switches count from the first time the process runs onwards
- `creation_time` is set at process allocation (fork/exec time)
- Accumulated `total_wait_time` includes time waiting at various points during execution
- Thread-safe access with spinlocks where needed
