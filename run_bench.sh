#!/opt/homebrew/bin/bash
# run_bench.sh — macOS-compatible xv6 benchmark for all schedulers

set -e
cd "$(dirname "$0")"

# QEMU and OpenSBI paths (update if installed differently)
QEMU="qemu-system-riscv64"
OPENBI="/opt/homebrew/share/qemu/opensbi-riscv64-generic-fw_dynamic.bin"
QEMU_OPTS="-machine virt -bios none \
           -kernel kernel/kernel -m 128M -smp 1 -nographic \
           -drive file=fs.img,format=raw,if=virtio"

# Benchmark parameters
BENCH_ARGS="4 4 1000000 3"    # ncpu nio cpu_iters io_rounds
BOOT_DELAY=5                   # seconds to wait for xv6 shell
RUN_TIMEOUT=60                 # seconds for benchmark to finish

SCHEDULERS="RR MLFQ MLFQ_AQ"
declare -A RESULTS

# macOS doesn't have timeout by default; use gtimeout from coreutils
if ! command -v gtimeout &>/dev/null; then
  echo "Please install coreutils: brew install coreutils"
  exit 1
fi

run_scheduler() {
  local sched=$1
  echo ""
  echo "=========================================="
  echo "  Building xv6 with SCHED_TYPE=$sched"
  echo "=========================================="
  
  make clean > /dev/null 2>&1
  make SCHED_TYPE="$sched" > /dev/null 2>&1
  make SCHED_TYPE="$sched" fs.img > /dev/null 2>&1
  echo "  Build OK. Running benchmark..."

  OUTPUT_FILE="${sched}.txt"

  # Run QEMU with benchsched
  gtimeout $((BOOT_DELAY + RUN_TIMEOUT + 10)) $QEMU $QEMU_OPTS \
    -kernel kernel/kernel \
    -serial mon:stdio \
    -display none \
    -S -s \
    < <(sleep $BOOT_DELAY; echo "benchsched $BENCH_ARGS"; sleep $RUN_TIMEOUT) \
    > "$OUTPUT_FILE" 2>&1 || true

  # Capture benchmark section
  local bench_section
  bench_section=$(sed -n '/=== SCHEDULER BENCHMARK ===/,/=== END BENCHMARK ===/p' "$OUTPUT_FILE")
  if [ -z "$bench_section" ]; then
    echo "  WARNING: No benchmark output captured for $sched"
    RESULTS[$sched]="(no output)"
  else
    RESULTS[$sched]="$bench_section"
    echo "$bench_section"
  fi
}

# Run all schedulers
for sched in $SCHEDULERS; do
  run_scheduler "$sched"
done

# Rebuild default (MLFQ_AQ)
make clean > /dev/null 2>&1
make > /dev/null 2>&1
make fs.img > /dev/null 2>&1

# Print comparison
echo ""
echo "================ Scheduler Metrics Comparison ================"
printf "%-28s %8s %8s %8s\n" "Metric" "RR" "MLFQ" "MLFQ_AQ"
printf "%-28s %8s %8s %8s\n" "----------------------------" "--------" "--------" "--------"

get_val() {
  local sched="$1"
  local section="$2"
  local label="$3"
  echo "${RESULTS[$sched]}" | awk "/$section/{found=1} found && /$label/{match(\$0,/[0-9]+/); print substr(\$0,RSTART,RLENGTH); found=0; exit}"
}

print_row() {
  local metric="$1" section="$2" label="$3"
  local rr mlfq aq
  rr=$(get_val "RR" "$section" "$label")
  mlfq=$(get_val "MLFQ" "$section" "$label")
  aq=$(get_val "MLFQ_AQ" "$section" "$label")
  printf "%-28s %8s %8s %8s\n" "$metric" "${rr:-N/A}" "${mlfq:-N/A}" "${aq:-N/A}"
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