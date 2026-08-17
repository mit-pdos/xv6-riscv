        # qemu -kernel loads the kernel at 0x80000000
        # and causes each hart (i.e. CPU) to jump there.
        # kernel.ld causes the following code to
        # be placed at 0x80000000.
.section .text
.global _entry
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        # 4096 = 2^12: multiply-by-constant is a shift.
        # No M extension needed -- and still correct for ANY hart count.
        la sp, stack0
        csrr a1, mhartid
        addi a1, a1, 1
        slli a1, a1, 12
        add sp, sp, a1
        # jump to start() in start.c
        call start
spin:
        j spin
