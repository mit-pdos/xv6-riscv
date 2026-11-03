#!/bin/sh
# bar stands for Build and Run

echo "Running test-xv6.py."
python3 test-xv6.py

echo "Running make clean."
make clean

echo "Running make qemu."
make qemu
