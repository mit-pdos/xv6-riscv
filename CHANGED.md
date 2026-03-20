# xv6-riscv: Simple Guide to What Was Added

This note explains two things in order:

1. Background: how xv6 process/syscall flow works in this codebase.
2. Changes: what was added (`getprocinfo`, `ps`, `procinfo`, `myproc`) and why it works.

---

## 1) Background: How This xv6 Works

## 1.1 Process storage in kernel

- xv6 keeps all processes in a fixed-size process table (`proc[NPROC]`).
- Each entry is a `struct proc` with fields like:
	- `pid`
	- `state` (`UNUSED`, `RUNNABLE`, `RUNNING`, `SLEEPING`, `ZOMBIE`, ...)
	- `parent`
	- `sz` (process memory size)
	- `name`
- These are defined in `kernel/proc.h`.

Important idea:

- Kernel code must hold a process lock (`p->lock`) before reading/changing process state safely.

## 1.2 How a syscall travels from user code to kernel code

When a user program calls a syscall, the path is:

1. User C function declaration in `user/user.h`.
2. Assembly syscall stub generated from `user/usys.pl`.
3. Trap into kernel via `ecall`.
4. Kernel dispatcher in `kernel/syscall.c`:
	 - reads syscall number from register `a7`
	 - calls the matching `sys_*` function
5. Handler implementation in files like `kernel/sysproc.c`.
6. Return value placed back for user code.

So adding a new syscall always means touching multiple files, not just one.

## 1.3 Sharing structs between kernel and user programs

- In this xv6 layout, user programs can include headers from `kernel/` (for shared types).
- That is why shared types like `struct stat` and now `struct pinfo` can be in `kernel/*.h`.

## 1.4 How user programs are included in xv6 image

- User binaries listed in `UPROGS` in `Makefile` get built and packed into `fs.img`.
- If a program is not in `UPROGS`, it will not be available in xv6 shell.

---

## 2) What Was Added

## 2.1 Shared process info struct

File: `kernel/pinfo.h`

Added:

- `struct pinfo` with:
	- `pid`
	- `parent_pid`
	- `state`
	- `sz`
	- `name[16]`
- State constants (`PSTATE_*`) matching kernel process-state enum values.

Note:

- `tickets` and `rtime` were not added because this codebase does not currently expose those fields in `struct proc`.

## 2.2 New syscall: `getprocinfo(int pid, struct pinfo *info)`

### Files updated

- `kernel/syscall.h`
	- Added syscall number: `SYS_getprocinfo 22`.

- `kernel/syscall.c`
	- Added `extern uint64 sys_getprocinfo(void);`
	- Added entry in syscall dispatch table.

- `kernel/sysproc.c`
	- Implemented `sys_getprocinfo`:
		1. reads `pid` and user pointer args
		2. scans process table for matching live process
		3. fills `struct pinfo`
		4. uses `copyout()` to copy struct to user memory
		5. returns `0` on success, `-1` on failure

- `user/usys.pl`
	- Added `entry("getprocinfo");` so user stub is generated.

- `user/user.h`
	- Added forward declaration `struct pinfo;`
	- Added user syscall prototype `int getprocinfo(int, struct pinfo*);`

Why this works:

- User code calls `getprocinfo(...)`.
- Stub places syscall number in `a7` and executes `ecall`.
- Kernel dispatches to `sys_getprocinfo`.
- Kernel safely copies result back with `copyout`.

## 2.3 New command: `ps`

File: `user/ps.c`

What it does:

- Prints a process table header:
	- `PID PPID STATE MEM NAME`
- Iterates candidate PIDs and calls `getprocinfo(pid, &info)`.
- If call succeeds, prints one row.
- Converts numeric process state to readable text.

Why this works:

- It is a user-level wrapper that repeatedly uses the new syscall.
- No scheduler internals were changed.

## 2.4 New command: `procinfo <pid>`

File: `user/procinfo.c`

What it does:

- Validates command-line argument.
- Calls `getprocinfo(pid, &info)` once.
- Prints detailed formatted process data:
	- PID
	- Parent PID
	- State
	- Memory Size
	- Name

Why this works:

- It is a single-process view using the same syscall data path as `ps`.

## 2.5 User workload program: `myproc`

File: `user/myproc.c`

Current behavior:

- Runs for about 10 seconds.
- Prints `Running process...` periodically.
- Uses `pause(...)` in loop to avoid busy waiting.
- Exits automatically.

Timing logic:

- Uses `uptime()` ticks to measure elapsed time.
- Target is `1000` ticks (about 10s in this xv6 setup).

## 2.6 Build integration

File: `Makefile`

Added under `UPROGS`:

- `$U/_ps`
- `$U/_procinfo`
- `$U/_myproc`

So after build, these commands are available in xv6 shell.

---

## 3) End-to-end flow (simple mental model)

For `procinfo 4`:

1. `procinfo` user binary calls `getprocinfo(4, &info)`.
2. Stub from `usys.S` executes `ecall` with syscall number 22.
3. Kernel syscall dispatcher maps 22 -> `sys_getprocinfo`.
4. Kernel finds PID 4 in process table and fills `struct pinfo`.
5. Kernel copies struct to user memory with `copyout`.
6. `procinfo` prints readable output.

For `ps`:

- Same as above, but repeated for many PIDs.

For `myproc &`:

- Shell forks a background process.
- `myproc` loops with sleep/pause, prints status, then exits automatically.

---

## 4) How to run and verify

1. Build and boot:

```sh
make qemu
```

2. In xv6 shell:

```sh
ps
procinfo 1
myproc &
ps
```

3. Expected:

- `ps` shows active processes.
- `procinfo <pid>` shows one process in detail.
- `myproc` runs briefly in background, prints periodically, and exits.

---

## 5) What was intentionally not changed

- No scheduler policy changes.
- No core scheduling logic modifications.
- No kernel panic paths intentionally introduced.

All additions are additive: new syscall + new user tools using existing xv6 mechanisms.