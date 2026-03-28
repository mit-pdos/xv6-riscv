#!/bin/bash

# Collection of test scripts for xv6-riscv metrics
# These scripts are designed to be run in the xv6 shell after building and starting the system

# Test 1: Basic Echo Test
test_echo() {
    echo "=== Test 1: Echo Command ==="
    echo "Hello from xv6-riscv metrics test"
    echo "Test 1 Complete"
    echo ""
}

# Test 2: Process Creation Test
test_fork() {
    echo "=== Test 2: Fork Test ==="
    if [ -x forktest ]; then
        forktest
    else
        echo "forktest not found, skipping fork test"
    fi
    echo ""
}

# Test 3: File Operations Test
test_files() {
    echo "=== Test 3: File Operations ==="
    ls -la
    if [ -f README ]; then
        echo "README EXISTS"
    fi
    echo ""
}

# Test 4: Concurrent Processes Test
test_concurrent() {
    echo "=== Test 4: Concurrent Execution ==="
    sh -c 'echo "Process 1" & echo "Process 2" & echo "Process 3" & wait'
    echo ""
}

# Test 5: Grep Search Test
test_grep() {
    echo "=== Test 5: Grep Search ==="
    if [ -f README ]; then
        grep -c "^" README
    fi
    echo ""
}

# Run all tests
echo "Starting xv6-riscv metrics test suite..."
echo "Timestamp: $(date)"
echo ""

test_echo
test_files
test_concurrent
test_fork
test_grep

echo "All tests completed."
