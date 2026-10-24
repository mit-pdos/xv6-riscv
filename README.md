# QEMU user-program tracing

## Build and run with a selected user program

The QEMU tracing plugin uses `USER_PROGRAM` to generate user-PC labels for one
executable. Build and start xv6 with the desired program, for example:

```sh
make qemu USER_PROGRAM=user/_bubblesort
```

You can select another built user executable, such as `user/_cat`:

```sh
make qemu USER_PROGRAM=user/_cat
```

`USER_PROGRAM` controls which executable the trace labels are based on; it does
not choose which command xv6 runs after boot. At the xv6 shell, run the command
you want to trace. The default for symbol generation is `user/_bubblesort`.
The plugin writes `qemu-trace.csv` in the repository root. Make sure the
executable and `.sym` file used for analysis match the selected program.

## Run the PolyBench 2mm benchmark

The PolyBench 2mm matrix-multiplication benchmark is included in the xv6 file
system image. Start xv6 with its executable selected for trace labels:

```sh
make qemu USER_PROGRAM=user/_polybench
```

At the xv6 shell, run the benchmark as a user process:

```sh
polybench
```

It prints elapsed xv6 ticks and a checksum for the result. `USER_PROGRAM`
selects the executable used to label the QEMU trace; it does not start the
benchmark automatically.

## Analyze a trace with the Python tools

Run the scripts from the repository root with Python 3. They need no third-party
Python packages:

```sh
# Overview of records, access sizes, and busiest PCs/addresses
python3 tools/trace_summary.py qemu-trace.csv --symbols user/bubblesort.sym

# Show reads/writes to an address; optionally inspect accesses at read values
python3 tools/trace_address.py qemu-trace.csv 0x5f78 \
  --symbols user/bubblesort.sym --follow-pointer

# Map user and memory PCs to the nearest preceding symbol
python3 tools/trace_symbols.py qemu-trace.csv user/bubblesort.sym

# Replay writes to one address or snapshot an aligned 4-byte integer array
python3 tools/trace_memory.py qemu-trace.csv --address 0x5f78
python3 tools/trace_memory.py qemu-trace.csv --array-base 0x14fe0 --count 5

# Pair each memory access with its disassembled instruction
python3 tools/trace_disasm.py qemu-trace.csv user/_bubblesort \
  --symbols user/bubblesort.sym

# Append per-page read/write counts, using the latest walk in pwalk.txt
python3 tools/trace_page_accesses.py qemu-trace.csv
```

The disassembly tool requires a RISC-V `objdump` executable in `PATH`. Symbol
mapping is approximate: `.sym` files map function symbols, not stack addresses
to local C variables. Trace memory replay only reflects recorded writes, and
the CSV may not identify the process that owned an address. The page-access
tool reports pages missing from the latest page-walk snapshot as unmapped.

## Ask the QEMU Trace Decoder agent

Open the repository's **QEMU Trace Decoder** agent and provide the trace and
matching symbols (and executable when instruction-level mapping is useful).
For example:

> Use `.github/workflows/agents/qemu-trace-decoder.agent.md` to interpret
> `qemu-trace.csv` from the `user/_bubblesort` run. Use
> `user/bubblesort.sym` to map PCs and `user/_bubblesort` for disassembly.
> Summarize the user-level memory reads and writes, including the input array,
> sorting passes, swaps, and final values. Distinguish observed facts from
> inferred C variables, and note any trace limitations. Format your response
> as a .md markdown file named `trace_mem.md`.

For a specific address, ask a focused question, for example:

> In `qemu-trace.csv`, explain accesses to `0x5f78` and whether its read values
> appear to be pointers. Trace accesses at those values too, but distinguish
> evidence from assumptions. Use `user/bubblesort.sym` and the matching
> executable if available. Format your response as a .md markdown file named
> `trace_add.md`
