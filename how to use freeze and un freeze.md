# How to Use Freeze and Unfreeze in xv6-riscv

This document explains how to use the `freeze` and `unfreeze` functionalities in the xv6-riscv project. These functionalities allow you to freeze and unfreeze processes, which can be useful for freeing the cpu for more important processes at this time.
We also added a `ps` command to list all processes and their statuses. This command is useful for checking the status of processes before freezing or unfreezing them.

## Using Freeze and Unfreeze from the Terminal

1. **Freeze a Process**:
    - Use the `freeze` command followed by the process ID (PID) to freeze a process.
    - Example:
      ```bash
      freeze 123
      ```
      This command freezes the process with PID 123.

2. **Unfreeze a Process**:
    - Use the `unfreeze` command followed by the process ID (PID) to unfreeze a process.
    - Example:
      ```bash
      unfreeze 123
      ```
      This command unfreezes the process with PID 123.

3. **List Processes**:
    - Use the `ps` command to list all processes and their statuses.
    - Example:
      ```bash
      ps
      ```
      This command displays a list of processes, including their PIDs and thier status (eg. RUNNING) and their names.
      
      ### example output:
        ```bash
        PID         Name           Status
         1             init           RUNNING
        ```

## Using Freeze and Unfreeze from the Code

1. **Freeze a Process**:
    - Call the `freeze(pid)` function in the code, where `pid` is the process ID of the target process.
    - Example:
      ```c
      freeze(123);
      ```
      This freezes the process with PID 123.

2. **Unfreeze a Process**:
    - Call the `unfreeze(pid)` function in the code, where `pid` is the process ID of the target process.
    - Example:
      ```c
      unfreeze(123);
      ```
      This unfreezes the process with PID 123.

3. **Required Header Files**:
    - To use the `freeze` and `unfreeze` functions in the code, include the following header files:
      ```c
      #include "kernel/types.h"
      #include "user/user.h"
      ```

## What we have done so far
- We have added the `freeze` and `unfreeze` and `ps` functionalities to the xv6-riscv project.
- We have tested these functionalities to ensure they work as expected.
- We have documented the usage of these functionalities for future reference.
