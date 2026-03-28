// Example: How to Use Process Scheduling Metrics in xv6-riscv

// ============================================================================
// OPTION 1: Call from Kernel (easiest for testing)
// ============================================================================

// Add this to kernel/main.c after system initialization:

void
main(void) {
  // ... existing initialization code ...
  
  procinit();      // initialize processes
  trapinit();      // ... other initialization ...
  
  // Let the system run for a bit to collect metrics
  // Then you can examine them programmatically or add:
  // proc_print_metrics();  // Uncomment to print metrics at boot
}

// ============================================================================
// OPTION 2: Create a Syscall to Access Metrics (for user programs)
// ============================================================================

// File: kernel/syscall.h
// Add define:
#define SYS_get_proc_metrics 23

// File: kernel/syscall.c
// Add handler:
uint64 sys_get_proc_metrics(void) {
  int pid;
  struct proc *p;
  
  // Get the PID argument
  argint(0, &pid);
  
  // Find the process
  p = getproc(pid);  // You'd need to implement this lookup
  if(p == 0)
    return -1;
  
  // Return metrics (example returns average waiting time)
  return proc_avg_waiting_time(p);
}

// And add to the syscall handlers:
extern uint64 sys_get_proc_metrics(void);
// In the syscalls[] array:
[SYS_get_proc_metrics] sys_get_proc_metrics,

// File: user/user.h
// Add declaration:
uint get_proc_metrics(int pid);

// File: user/usys.pl
// Add entry:
entry("get_proc_metrics");

// File: user/ulib.c or a new metrics.c
// Add user-side wrapper:
uint get_proc_metrics(int pid) {
  return syscall(SYS_get_proc_metrics, pid);
}

// ============================================================================
// OPTION 3: Create a User Program to Display Metrics
// ============================================================================

// File: user/metrics.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

// If you add syscalls for individual metrics:
uint
sys_get_metrics(int pid, uint *buffer) {
  // buffer[0] = avg waiting time
  // buffer[1] = response time  
  // buffer[2] = context switches
  return syscall(SYS_get_metrics, pid, (uint64)buffer);
}

int
main(int argc, char *argv[]) {
  int pid;
  uint metrics[3];
  
  if(argc < 2) {
    fprintf(2, "Usage: metrics <pid>\n");
    exit(1);
  }
  
  pid = atoi(argv[1]);
  
  // Call syscall to get metrics
  if(get_metrics(pid, metrics) < 0) {
    fprintf(2, "Process not found\n");
    exit(1);
  }
  
  printf("PID: %d\n", pid);
  printf("Average Waiting Time: %d ticks\n", metrics[0]);
  printf("Response Time: %d ticks\n", metrics[1]);
  printf("Context Switches: %d\n", metrics[2]);
  
  exit(0);
}

// ============================================================================
// OPTION 4: Access via Debug/Shell Command
// ============================================================================

// If you have a debug shell command, add:
case 'm': // metrics command
  proc_print_metrics();
  break;

// Then in the shell you could type:
// ctrl-p (if mapped to debug) to print all metrics

// ============================================================================
// Key Functions to Remember
// ============================================================================

// To get average waiting time:
uint avg_wait = proc_avg_waiting_time(p);

// To get response time (first run time):
uint response = proc_response_time(p);

// To get context switch count:
uint ctx_switches = proc_context_switches(p);

// To print all process metrics:
proc_print_metrics();

// ============================================================================
// Interpreting Results
// ============================================================================

// Example output:
// PID    Name            Avg Wait    Response    Context Switches
// 1      init            5           10          3
// 2      sh              12          20          50
// 3      cat             8           15          2

// - init: Quick response time (10 ticks), switched out 3 times
// - sh: Slower response (20 ticks), many context switches (50) - interactive
// - cat: Medium response, few switches - running to completion

// Lower response time = more responsive scheduling
// More context switches = more interactive process
// Higher average wait = process waits longer between scheduling chances
