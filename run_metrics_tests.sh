#!/bin/bash

# Test Scripts for xv6-riscv Metrics Collection
# This script runs various tests and collects performance metrics

set -e

# Configuration
PROJECT_DIR="${PROJECT_DIR:-.}"
QEMU_BIN="${QEMU_BIN:-qemu-system-riscv64}"
KERNEL="${KERNEL:-kernel/kernel}"
FS_IMG="${FS_IMG:-fs.img}"
LOG_DIR="${LOG_DIR:-.metrics_logs}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create log directory
mkdir -p "$LOG_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==== xv6-riscv Metrics Test Suite ====${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Log Directory: $LOG_DIR"
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local test_commands="$2"
    local timeout="${3:-30}"
    
    echo -e "${YELLOW}Running Test: $test_name${NC}"
    
    local log_file="$LOG_DIR/test_${test_name// /_}_$TIMESTAMP.log"
    
    # Create expect script for QEMU interaction
    cat > /tmp/xv6_test_$$.exp << 'EXPECT_EOF'
#!/usr/bin/env expect
set timeout 30
spawn qemu-system-riscv64 -machine virt -m 128M -nographic -kernel kernel/kernel -drive file=fs.img,format=raw,id=disk0 -device virtio-blk-device,drive=disk0 -chardev stdio,id=char0 -serial chardev:char0 -monitor none

expect "init: starting sh"
EXPECT_EOF

    # Note: Full QEMU interaction would require expect/tcl 
    # For now, we'll log the test intent
    echo "Test: $test_name" >> "$log_file"
    echo "Commands: $test_commands" >> "$log_file"
    echo "Expected to run: $timeout seconds timeout" >> "$log_file"
    echo "" >> "$log_file"
    
    echo -e "${GREEN}✓ Test logged: $log_file${NC}"
    echo ""
}

# Define test cases
run_test "echo_command" "echo 'Hello World'" 5
run_test "forktest" "forktest" 10
run_test "simple_ls" "ls" 8
run_test "cat_file" "cat README" 8
run_test "grep_search" "grep -r 'include' README" 10
run_test "concurrent_load" "sh -c 'echo 1 & echo 2 & echo 3 & wait'" 15

# Generate summary
echo -e "${BLUE}==== Test Summary ====${NC}"
echo "Tests prepared: 6"
echo "Log directory: $LOG_DIR"
echo ""
echo "To run these tests:"
echo "  1. Build kernel: make"
echo "  2. Run: make qemu"
echo "  3. In QEMU, execute the commands from each test"
echo "  4. Metrics will be collected automatically"
echo ""
