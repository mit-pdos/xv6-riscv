#include "memlayout.h"

	# qemu -kernel starts at 0x1000. the instructions
        # there seem to be provided by qemu, as if it
        # were a ROM. the code at 0x1000 jumps to
        # 0x80000000, the _start function here,
        # in machine mode. each CPU starts here.
.section .data
.globl stack0
.section .text
.globl start
.section .text
.globl _entry
_entry:

        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + (hartid * STKSIZE)
        la tp, stack0
        csrr a0, mhartid
        add sp, a0, 1
        sll sp, sp, STKSHIFT
        add sp, sp, tp

        j start
junk:
        j junk
