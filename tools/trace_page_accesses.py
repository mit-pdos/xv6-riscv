#!/usr/bin/env python3
"""Append per-virtual-page read/write counts from a QEMU trace to pwalk.txt."""

import argparse
import re
import sys
from collections import Counter
from pathlib import Path

from trace_common import load_trace, memory_rows, parse_int


PAGE_SIZE = 4096
VPN_MASK = 0x1FF
SV39_PPN_MASK = (1 << 44) - 1
WALK_HEADER = re.compile(r"^=== pwalk call (0x[0-9a-fA-F]+) ===$")
WALK_ENTRY = re.compile(r"^L([210])\[([0-9a-fA-F]+)\] (0x[0-9a-fA-F]+)$")


def parse_page_walk(text: str) -> tuple[str, dict[tuple[int, int, int], int]]:
    snapshots: list[tuple[str, dict[tuple[int, int, int], int]]] = []
    vpn2 = vpn1 = None

    for line_number, line in enumerate(text.splitlines(), start=1):
        header = WALK_HEADER.fullmatch(line)
        if header:
            snapshots.append((header.group(1), {}))
            vpn2 = vpn1 = None
            continue

        if line.startswith(("L0[", "L1[", "L2[")):
            entry = WALK_ENTRY.fullmatch(line)
            if entry is None:
                raise ValueError(f"page walk line {line_number}: malformed entry")
            if not snapshots:
                raise ValueError(f"page walk line {line_number}: entry precedes walk header")

            level, index, pte = int(entry.group(1)), int(entry.group(2), 16), int(
                entry.group(3), 16
            )
            if index > VPN_MASK:
                raise ValueError(f"page walk line {line_number}: VPN index is out of range")

            if level == 2:
                vpn2, vpn1 = index, None
            elif level == 1:
                if vpn2 is None:
                    raise ValueError(f"page walk line {line_number}: L1 entry has no L2 parent")
                vpn1 = index
            else:
                if vpn2 is None or vpn1 is None:
                    raise ValueError(f"page walk line {line_number}: L0 entry has no parent path")
                if pte & 1 and pte & 0xE:
                    key = (vpn2, vpn1, index)
                    pages = snapshots[-1][1]
                    if key in pages and pages[key] != pte:
                        raise ValueError(
                            f"page walk line {line_number}: conflicting PTE for VPN "
                            f"{vpn2:03x}/{vpn1:03x}/{index:03x}"
                        )
                    pages[key] = pte

    if not snapshots:
        raise ValueError("page walk contains no '=== pwalk call ... ===' sections")
    call, pages = snapshots[-1]
    if not pages:
        raise ValueError(f"page walk call {call} contains no valid L0 mappings")
    return call, pages


def vpn_for_address(address: int) -> tuple[int, int, int]:
    return (
        (address >> 30) & VPN_MASK,
        (address >> 21) & VPN_MASK,
        (address >> 12) & VPN_MASK,
    )


def virtual_page_base(vpn: tuple[int, int, int]) -> int:
    address = (vpn[0] << 30) | (vpn[1] << 21) | (vpn[2] << 12)
    if address & (1 << 38):
        address |= ((1 << 64) - 1) ^ ((1 << 39) - 1)
    return address


def format_report(
    trace_path: Path,
    call: str,
    pages: dict[tuple[int, int, int], int],
    counts: dict[tuple[int, int, int], Counter[str]],
) -> str:
    lines = [
        f"=== memory accesses by virtual page (trace: {trace_path}; pwalk call: {call}) ===",
        "An access spanning pages is counted once for each page it touches.",
    ]
    mapped_accesses = 0
    total_reads = total_writes = 0
    for vpn in sorted(counts, key=virtual_page_base):
        page_counts = counts[vpn]
        reads, writes = page_counts["read"], page_counts["write"]
        total_reads += reads
        total_writes += writes
        va_page = virtual_page_base(vpn)
        pte = pages.get(vpn)
        if pte is None:
            lines.append(
                f"VA page 0x{va_page:016x} -> not present in pwalk: "
                f"reads={reads} writes={writes}"
            )
        else:
            pa_page = ((pte >> 10) & SV39_PPN_MASK) << 12
            mapped_accesses += reads + writes
            lines.append(
                f"VA page 0x{va_page:016x} -> PA page 0x{pa_page:016x}: "
                f"reads={reads} writes={writes}"
            )

    lines.append(
        f"Totals: page accesses={total_reads + total_writes} reads={total_reads} "
        f"writes={total_writes} mapped={mapped_accesses} "
        f"unmapped={total_reads + total_writes - mapped_accesses}"
    )
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "trace",
        nargs="?",
        type=Path,
        default=Path("qemu-trace.csv"),
        help="QEMU trace CSV (default: qemu-trace.csv)",
    )
    parser.add_argument(
        "--page-walk",
        type=Path,
        default=Path("pwalk.txt"),
        help="page-walk input and report output (default: pwalk.txt)",
    )
    args = parser.parse_args()

    try:
        rows = memory_rows(load_trace(args.trace))
        page_walk_text = args.page_walk.read_text()
        call, pages = parse_page_walk(page_walk_text)
        counts: dict[tuple[int, int, int], Counter[str]] = {}
        for row in rows:
            address = parse_int(row["address"])
            size = parse_int(row["size"])
            if size < 1:
                raise ValueError(f"trace row {row['_row']}: access size must be positive")
            last_address = address + size - 1
            page_base = address & ~(PAGE_SIZE - 1)
            last_page_base = last_address & ~(PAGE_SIZE - 1)
            for touched_page in range(page_base, last_page_base + PAGE_SIZE, PAGE_SIZE):
                vpn = vpn_for_address(touched_page)
                counts.setdefault(vpn, Counter())[row["operation"]] += 1

        report = format_report(args.trace, call, pages, counts)
        with args.page_walk.open("a") as output:
            separator = "" if not page_walk_text or page_walk_text.endswith("\n") else "\n"
            output.write(separator + "\n" + report)
    except (OSError, ValueError) as error:
        print(f"trace_page_accesses.py: {error}", file=sys.stderr)
        return 1

    print(report, end="")
    print(f"Appended page access counts to {args.page_walk}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
