#!/bin/sh

echo "Installing Python and Make"
sudo apt update
sudo apt install -y python3 make

echo "Installing RISC-V toolchain and QEMU"
sudo apt install -y gcc-riscv64-unknown-elf
sudo apt install -y binutils-riscv64-unknown-elf
sudo apt install -y qemu-system-misc

echo "Run bar.sh to boot into BomboclatOS"
