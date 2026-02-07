Here’s a concise documentation snapshot you can keep alongside the project.

---

## Swap Phase 1 – Implementation Summary

### Kernel Changes
- **Swap flag & metadata**
  - Added `PTE_SWAP` and helper macros in `kernel/riscv.h`.
  - Each `struct proc` now tracks swap entries (`swap_entries[]`) and a wait channel for swap-ins.
- **Kernel swap daemons**
  - `swap_init()` now launches `kswapout` and `kswapin` kernel processes.
  - Added queues, slot management, and synchronization in `kernel/swap.c` to handle swap-out/in requests entirely in memory (per assignment guidance against direct kernel file I/O).
- **Memory management hooks**
  - `kalloc()` blocks on `swap_request_memory()` when free pages run out.
  - `usertrap()` and `vmfault()` detect `PTE_SWAP` faults, enqueue swap-in work, and sleep until the page is restored.
  - `uvmunmap()`, `uvmcopy()`, and `growproc()`/`exec()` clean up swap metadata and slots for freed ranges or new images.
- **Support utilities**
  - Exposed swap helper prototypes in `kernel/defs.h`.
  - Added `swapstress` test program and registered it in the build (`Makefile`, new `user/swapstress.c`).

### How to Build & Run
1. **Lower physical memory (forces swap)**
   - Edit `kernel/memlayout.h`: set `PHYSTOP` to a smaller value (e.g., `32*1024*1024`).
2. **Rebuild**
   ```sh
   make clean
   make -j4
   make fs.img
   ```
3. **Boot xv6**
   ```sh
   make qemu
   ```

### Testing Procedure
At the xv6 shell:
```sh
$ swapstress
```
- Each of 20 children allocates 10 pages (4 KB each), fills them, and reads them back.
- With reduced RAM, pages should be swapped out and in by the daemons.
- Successful run prints `swapstress: success`. Any failure message indicates data corruption or swap malfunction.

Optional runtime checks:
- Press **Ctrl + p** during execution to confirm `kswapout`/`kswapin` are active and user processes cycle through `sleep`/`running`.
- Look for additional debug prints (if you add any) around swap events.

### Verification Checklist
- Kernel boots normally; `swapstress` completes under low `PHYSTOP`.
- No processes remain stuck in `sleep` after the test.
- Restoring `PHYSTOP` and rebuilding returns the system to standard behavior.

Restore `PHYSTOP` to `128*1024*1024` when you’ve finished testing.

---

This summary captures the implementation scope, how to exercise it, and the expected signals that swapping works end-to-end.