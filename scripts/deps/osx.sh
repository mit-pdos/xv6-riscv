#!/bin/sh

echo "Install Brew at brew.sh"

echo "Installing python and make"
brew install python3, make

echo "Installing RISC-V toolchain and QEMU"
brew tap riscv-software-src/riscv
brew trust riscv-software-src/riscv
brew install riscv-tools
brew install qemu

echo "Run bar.sh to boot into BomboclatOS"
