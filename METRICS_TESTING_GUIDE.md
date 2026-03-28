# Metrics Testing and Data Collection Guide

## Overview

This directory contains tools for collecting, analyzing, and storing performance metrics from xv6-riscv in CSV format for analysis.

## Files

### Test Scripts
- **`run_metrics_tests.sh`** - Main test script that defines various test cases
- **`analyze_metrics.py`** - Python script to parse metrics output and export to CSV format

### Documentation
- **`BASELINE_METRICS.md`** - Reference baseline values for comparison
- **`METRICS_SUMMARY.md`** - Complete metrics implementation reference

## Quick Start

### 1. Build the Kernel
```bash
cd /Users/zin/OSProject/xv6-riscv
make clean
make
```

### 2. Generate Baseline Metrics CSV
```bash
python3 analyze_metrics.py --baseline --output-dir metrics_data
```

This creates `metrics_data/baseline_metrics.csv` with expected values for all metrics.

### 3. Run xv6 and Collect Metrics

#### Option A: Interactive Shell
```bash
make qemu
```

Then run these commands in the xv6 shell:
```
echo "Hello World"
forktest
ls
cat README
```

#### Option B: Using test script (structure for automation)
```bash
bash run_metrics_tests.sh
```

### 4. Export Metrics

After running tests, export the metrics to CSV:

#### From kernel output (if captured to file):
```bash
# Capture kernel metrics to a file
# (In xv6 shell, you would call: proc_print_extended_metrics from a debug command)

# Then export to CSV:
python3 analyze_metrics.py --input metrics.log --combined --output-dir metrics_data
```

#### Generate combined CSV:
```bash
python3 analyze_metrics.py --combined --output-dir metrics_data
```

## CSV Format

### Process Metrics CSV
```
timestamp,pid,name,turnaround_time_ticks,avg_wait_ticks,response_time_ticks,context_switches
2026-03-20T12:30:45.123456,1,init,150,25,10,3
2026-03-20T12:30:45.123456,2,sh,200,45,20,8
```

### System Metrics CSV
```
timestamp,metric,value,unit
2026-03-20T12:30:45.123456,Elapsed Time (ticks),5000,ticks
2026-03-20T12:30:45.123456,Total Processes Created,5,count
2026-03-20T12:30:45.123456,Total Context Switches,45,count
2026-03-20T12:30:45.123456,CPU Utilization,95,percent
```

### Combined Metrics CSV
```
timestamp,category,metric,pid,value,unit
2026-03-20T12:30:45.123456,system,Elapsed Time (ticks),,5000,ticks
2026-03-20T12:30:45.123456,process,Turnaround Time,1,150,ticks
2026-03-20T12:30:45.123456,process,Context Switches,1,3,count
```

## Baseline Metrics CSV Format
```
metric,expected_value,min_value,max_value,unit,description
Boot Time,1000,500,1500,ticks,Time from start to first process ready
Simple Echo Duration,100,50,150,ticks,Execution time of echo command
Process Creation Time,60,20,100,ticks,Time for fork() syscall
```

## Using Metrics in Kernel Code

### Call from main() or another kernel function:
```c
#include "defs.h"

void
main(void)
{
  // ... initialization code ...
  
  // Print metrics in human-readable format
  proc_print_extended_metrics();
  
  // Print CSV headers and data
  proc_print_csv_header();
  proc_print_csv_data();
  
  // Print system metrics in CSV
  proc_print_system_csv();
}
```

### Available Functions:
- `proc_print_metrics()` - Basic metrics table
- `proc_print_extended_metrics()` - Full metrics with system stats
- `proc_print_csv_header()` - CSV header for process metrics
- `proc_print_csv_data()` - CSV data for process metrics
- `proc_print_system_csv()` - CSV data for system metrics

## Test Cases

### Test 1: Single User Process
```bash
echo "Hello World"
```
**Expected Metrics (from baseline)**:
- Response Time: 10-20 ticks
- Context Switches: 5-10
- Turnaround Time: 100-200 ticks

### Test 2: Fork and Wait
```bash
forktest
```
**Expected Metrics**:
- Multiple processes created sequentially
- Context Switches: 100+
- All processes complete successfully

### Test 3: Interactive Shell Load
```bash
(echo "ls"; sleep 1; echo "cat README"; sleep 1;) | sh
```
**Expected Metrics**:
- Throughput: 2-5 commands/second
- Response Time: 10-30 ticks per command
- Context Switches: 5-15 per command

### Test 4: Concurrent Load
```bash
sh -c 'echo 1 & echo 2 & echo 3 & wait'
```
**Expected Metrics**:
- CPU Utilization: 95-100%
- Context Switches/sec: 50-200
- Fair scheduling among processes

## Data Analysis

### Using Python for analysis:
```python
import pandas as pd

# Load process metrics
df = pd.read_csv('metrics_data/processes_20260320_120000.csv')

# Analyze turnaround times
print(df[['pid', 'name', 'turnaround_time_ticks']].describe())

# Plot metrics
import matplotlib.pyplot as plt
df.plot(x='pid', y='response_time_ticks', kind='bar')
plt.show()
```

### Using baseline for comparison:
```python
# Load baseline
baseline = pd.read_csv('metrics_data/baseline_metrics.csv')

# Load actual metrics
actual = pd.read_csv('metrics_data/system_20260320_120000.csv')

# Check against baseline
for idx, row in actual.iterrows():
    base = baseline[baseline['metric'] == row['metric']]
    if not base.empty and row['value'] > base['max_value'].values[0]:
        print(f"ALERT: {row['metric']} exceeds baseline!")
```

## Workflow for Continuous Testing

1. Make changes to scheduler or process management
2. Rebuild: `make clean && make`
3. Run xv6: `make qemu`
4. Execute test cases and capture output
5. Export to CSV: `python3 analyze_metrics.py ...`
6. Compare with baseline: `diff baseline_metrics.csv new_metrics.csv`
7. Analyze trends in metrics_data/

## Troubleshooting

### Missing CSV files
- Check that `metrics_data/` directory exists
- Create manually: `mkdir -p metrics_data`

### CSV export not working
- Verify Python 3.6+ is installed
- Check file permissions in metrics_data/
- Run with verbose output: `python3 analyze_metrics.py -h`

### Metrics not being collected
- Ensure kernel was rebuilt: `make clean && make`
- Verify `proc.c` and `defs.h` changes are present
- Call metric functions from main() or debug handler

## References

- See [BASELINE_METRICS.md](BASELINE_METRICS.md) for expected values
- See [METRICS_SUMMARY.md](METRICS_SUMMARY.md) for implementation details
- See [METRICS_DOCUMENTATION.md](METRICS_DOCUMENTATION.md) for full API
