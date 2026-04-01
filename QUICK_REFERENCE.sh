#!/bin/bash

# Quick Reference: Metrics Collection Workflow
# This file shows the exact commands to use for metrics testing and analysis

echo "=================================================="
echo "xv6-riscv Metrics Collection - Quick Reference"
echo "=================================================="
echo ""

# Section 1: Build and Setup
echo "1. BUILD KERNEL"
echo "   cd /Users/zin/OSProject/xv6-riscv"
echo "   make clean && make"
echo ""

# Section 2: Generate Baseline
echo "2. GENERATE BASELINE METRICS"
echo "   python3 analyze_metrics.py --baseline --output-dir metrics_data"
echo "   (Creates: metrics_data/baseline_metrics.csv)"
echo ""

# Section 3: Run xv6
echo "3. START QEMU WITH xv6"
echo "   make qemu"
echo ""

# Section 4: In xv6 Shell - Test Commands
echo "4. RUN TEST COMMANDS (in xv6 shell)"
echo "   Source test script:"
echo "   $ source /dev/stdin < metrics_test.sh"
echo ""
echo "   Or run individual tests:"
echo "   $ echo Hello World"
echo "   $ forktest"
echo "   $ ls"
echo "   $ cat README"
echo ""

# Section 5: Collect Metrics (if implemented)
echo "5. COLLECT METRICS"
echo "   (Add to kernel main() or debug handler):"
echo "   proc_print_csv_header();"
echo "   proc_print_csv_data();"
echo "   proc_print_system_csv();"
echo ""

# Section 6: Export to CSV
echo "6. EXPORT METRICS TO CSV"
echo "   # If metrics were saved to file:"
echo "   python3 analyze_metrics.py --input metrics.log --combined --output-dir metrics_data"
echo ""
echo "   # Or generate combined CSV:"
echo "   python3 analyze_metrics.py --combined --output-dir metrics_data"
echo ""

# Section 7: Analyze Data
echo "7. ANALYZE CSV DATA"
echo "   python3 << 'EOF'"
echo "   import pandas as pd"
echo "   baseline = pd.read_csv('metrics_data/baseline_metrics.csv')"
echo "   actual = pd.read_csv('metrics_data/processes_*.csv')"
echo "   "
echo "   print('Process Metrics:')"
echo "   print(actual[['pid', 'name', 'turnaround_time_ticks', 'context_switches']])"
echo "   "
echo "   print('\\nSummary Statistics:')"
echo "   print(actual.describe())"
echo "   EOF"
echo ""

# Section 8: Available Functions
echo "8. KERNEL METRICS FUNCTIONS"
echo "   Display Functions:"
echo "   - proc_print_metrics()           // Basic metrics table"
echo "   - proc_print_extended_metrics() // Full metrics + system stats"
echo ""
echo "   CSV Export Functions:"
echo "   - proc_print_csv_header()       // CSV header for processes"
echo "   - proc_print_csv_data()         // CSV data for processes"
echo "   - proc_print_system_csv()       // System metrics in CSV"
echo ""
echo "   Query Functions:"
echo "   - proc_avg_waiting_time(p)      // Average wait time (ticks)"
echo "   - proc_response_time(p)         // Response time (ticks)"
echo "   - proc_turnaround_time(p)       // Turnaround time (ticks)"
echo "   - proc_context_switches(p)      // Context switch count"
echo "   - proc_cpu_utilization()        // CPU usage percentage"
echo "   - proc_throughput()             // Processes completed"
echo "   - get_elapsed_time()            // Time since boot (ticks)"
echo ""

# Section 9: CSV File Formats
echo "9. CSV FILE FORMATS"
echo ""
echo "   Process Metrics:"
echo "   timestamp,pid,name,turnaround_time,avg_wait,response_time,context_switches"
echo "   2026-03-20T12:30:45,1,init,150,25,10,3"
echo ""
echo "   System Metrics:"
echo "   timestamp,metric,value,unit"
echo "   2026-03-20T12:30:45,Elapsed Time (ticks),5000,ticks"
echo ""
echo "   Baseline Reference:"
echo "   metric,expected_value,min_value,max_value,unit,description"
echo "   Boot Time,1000,500,1500,ticks,Time from start to ready"
echo ""

# Section 10: Directory Structure
echo "10. OUTPUT DIRECTORY STRUCTURE"
echo "    metrics_data/"
echo "    ├── baseline_metrics.csv          (Reference values)"
echo "    ├── processes_20260320_*.csv      (Per-process metrics)"
echo "    ├── system_20260320_*.csv         (System metrics)"
echo "    └── metrics_20260320_*.csv        (Combined metrics)"
echo ""

# Section 11: Troubleshooting
echo "11. TROUBLESHOOTING"
echo ""
echo "    Problem: Python script not found"
echo "    Solution: python3 analyze_metrics.py --help"
echo ""
echo "    Problem: CSV files not created"
echo "    Solution: mkdir -p metrics_data"
echo ""
echo "    Problem: Kernel not compiling"
echo "    Solution: make clean && make 2>&1 | tail -20"
echo ""
echo "    Problem: Metrics not being collected"
echo "    Solution: Add proc_print_*() calls to kernel/main.c"
echo ""

# Section 12: Performance Baselines
echo "12. PERFORMANCE BASELINES (Expected Values)"
echo ""
echo "    Metric                          Expected    Min     Max     Unit"
echo "    Boot Time                       1000        500     1500    ticks"
echo "    Simple Echo Command             100         50      150     ticks"
echo "    Process Creation Time           60          20      100     ticks"
echo "    Response Time (single process)  15          5       30      ticks"
echo "    Context Switches/Second         200         50      500     count"
echo "    CPU Utilization (idle)          0           0       10      %"
echo "    CPU Utilization (loaded)        95          80      100     %"
echo ""

echo "=================================================="
echo "For detailed information, see:"
echo "  - BASELINE_METRICS.md       (Baseline values and interpretation)"
echo "  - METRICS_TESTING_GUIDE.md  (Complete testing guide)"
echo "  - METRICS_SUMMARY.md        (Implementation reference)"
echo "  - IMPLEMENTATION_CHECKLIST  (Feature completion status)"
echo "=================================================="
