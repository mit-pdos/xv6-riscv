#!/bin/zsh
# benchmark_mac.sh — build xv6 with each scheduler, run benchsched, compare results.
# macOS compatible version.

set -e
cd "$(dirname "$0")"

# Simplified QEMU for macOS
QEMU="qemu-system-riscv64"
QEMU_OPTS="-machine virt -kernel kernel/kernel -m 128M -smp 1 -nographic \
  -drive file=fs.img,format=raw,if=virtio"

# Benchmark parameters: ncpu nio cpu_iters io_rounds
BENCH_ARGS="6 4 5000000 5"
BOOT_DELAY=6      # seconds to wait for xv6 shell
RUN_TIMEOUT=120   # seconds to allow benchmark to finish

SCHEDULERS="RR MLFQ MLFQ_AQ"
declare RESULTS

run_scheduler() {
  local sched=$1
  echo ""
  echo "=========================================="
  echo "  Building xv6 with SCHEDULER=$sched"
  echo "=========================================="
  make clean > /dev/null 2>&1
  make SCHEDULER="$sched" > /dev/null 2>&1
  make SCHEDULER="$sched" fs.img > /dev/null 2>&1
  echo "  Build OK. Running benchmark..."

  # Run QEMU and execute benchsched
  local output
  output=$(
    (sleep $BOOT_DELAY && echo "benchsched $BENCH_ARGS" && sleep $RUN_TIMEOUT) \
    | $QEMU $QEMU_OPTS 2>&1 \
    | sed 's/\r//'
  ) || true

  local bench_section
  bench_section=$(echo "$output" | sed -n '/=== SCHEDULER BENCHMARK ===/,/=== END BENCHMARK ===/p')

  if [ -z "$bench_section" ]; then
    echo "  WARNING: No benchmark output captured for $sched"
    echo "  --- raw output (last 10 lines) ---"
    echo "$output" | tail -10
    RESULTS[$sched]="(no output)"
  else
    RESULTS[$sched]="$bench_section"
    echo "$bench_section"
  fi
}

# Run all three schedulers
for sched in $SCHEDULERS; do
  run_scheduler "$sched"
done

# Rebuild default (MLFQ_AQ) so normal 'make qemu' still works
make clean > /dev/null 2>&1
make > /dev/null 2>&1
make fs.img > /dev/null 2>&1

# Print comparison
echo ""
echo "############################################"
echo "#       SCHEDULER COMPARISON SUMMARY       #"
echo "############################################"

get_val() {
  local section="$1" label="$2" sched="$3"
  echo "${RESULTS[$sched]}" \
    | awk "/$section/{found=1} found && /$label/{match(\$0,/[0-9]+/); print substr(\$0,RSTART,RLENGTH); found=0; exit}"
}

printf "\n%-28s %8s %8s %8s\n" "Metric" "RR" "MLFQ" "MLFQ_AQ"
printf "%-28s %8s %8s %8s\n" "----------------------------" "--------" "--------" "--------"

print_row() {
  local metric="$1" section="$2" label="$3"
  local rr mlfq mlfq_aq
  rr=$(get_val "$section" "$label" "RR")
  mlfq=$(get_val "$section" "$label" "MLFQ")
  mlfq_aq=$(get_val "$section" "$label" "MLFQ_AQ")
  printf "%-28s %8s %8s %8s\n" "$metric" "${rr:-N/A}" "${mlfq:-N/A}" "${mlfq_aq:-N/A}"
}

print_row "CPU  Avg response (ticks)"   "CPU-bound"   "Avg response"
print_row "CPU  Avg turnaround (ticks)" "CPU-bound"   "Avg turnaround"
print_row "CPU  Avg wait (ticks)"       "CPU-bound"   "Avg wait"
print_row "IO   Avg response (ticks)"   "IO-bound"    "Avg response"
print_row "IO   Avg turnaround (ticks)" "IO-bound"    "Avg turnaround"
print_row "IO   Avg wait (ticks)"       "IO-bound"    "Avg wait"
print_row "Elapsed (ticks)"             "System-wide" "Elapsed"
print_row "Throughput (proc/100ticks)"  "System-wide" "Throughput"
print_row "Sys context switches"        "System-wide" "Sys ctx"
print_row "Total CPU time (ticks)"      "System-wide" "Total CPU"

echo ""
echo "Lower response/turnaround/wait = better."
echo "Higher throughput = better."