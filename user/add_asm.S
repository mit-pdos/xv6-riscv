#include "kernel/syscall.h"

.global main
main:
        addi sp, sp, -48
        sd ra, 40(sp)
        sd s0, 32(sp)
        sd s1, 24(sp)
        sd s2, 16(sp)
        sd s3, 8(sp)

        la s0, buf
        li s1, 0
        li s2, -1

loop:
        li a0, 0
        add a1, s0, s1
        li a2, 1
        call read
        blez a0, end_loop

        add t0, s0, s1
        lb t1, 0(t0)

        li t2, 10
        bne t1, t2, not_nl
        sb zero, 0(t0)
        j end_loop
not_nl:
        li t2, 32
        bne t1, t2, not_sp
        mv s2, s1
not_sp:
        addi s1, s1, 1
        j loop

end_loop:
        add t0, s0, s1
        sb zero, 0(t0)

        mv a0, s0
        call atoi
        mv s3, a0

        add a0, s0, s2
        addi a0, a0, 1
        call atoi
        mv a1, a0
        mv a0, s3
        call add
        mv s3, a0

        la a0, dbg
        mv a1, s0
        call printf

        la a0, res
        mv a1, s3
        call printf

        li a0, 0
        ld ra, 40(sp)
        ld s0, 32(sp)
        ld s1, 24(sp)
        ld s2, 16(sp)
        ld s3, 8(sp)
        addi sp, sp, 48
        ret

.section .data
buf:
        .space 100
dbg:
        .asciz "|%s|\n"
res:
        .asciz "%d\n"
