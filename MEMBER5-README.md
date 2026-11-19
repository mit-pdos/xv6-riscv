# Member 5 — getyear() Test Program and Documentation

## Project Information

- Repository: https://github.com/siripurapuhansuja/xv6-riscv
- Integration branch: xv6-project
- Baseline commit: fa2ddcb7ca87a77af579380a6eafd5aff163b44f

## Contribution

- Created `user/getyeartest.c` to test the `getyear()` system call.
- Added `$U/_getyeartest` to the Makefile's `UPROGS` list.
- Documented build and execution instructions.

## Requirements

Ubuntu with Git, GCC, Make, Perl, bc, QEMU, and RISC-V cross-compilation tools.

Install the packages using:

    sudo apt update
    sudo apt install git build-essential perl bc qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu

## Build and Run

From the xv6-riscv repository directory:

    make clean
    make qemu

At the xv6 shell prompt, run:

    getyeartest

## Expected Output

After all group members' system-call changes are integrated successfully:

    Kernel says year = 2026

This output was verified successfully during the QEMU test.

## Exit QEMU

Press Ctrl+A, release the keys, and press X.

## Validation Results

- `make` completed successfully.
- `make fs.img` completed successfully.
- `make qemu` launched xv6 successfully.
- Executed `getyeartest` inside the xv6 shell.
- Actual output:

      Kernel says year = 2026

The successful output confirms that the getyear() system call works correctly.
