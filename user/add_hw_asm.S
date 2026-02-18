.data
    buf:        .space 100
    fmt_str:    .asciz "|%s|\n"
    fmt_num:    .asciz "%d\n"

.text
.global main

main:
    li s0, 0    # i = 0

read_loop:
    # - if (i+1 >= 100) break
    li t0, 99
    bge s0, t0, read_done

    # read(0, &buf[i], 1)
    li a0, 0    # fd = stdin
    la t1, buf
    add a1, t1, s0  # &buf[i]
    li a2, 1    # size = 1
    li a7, 5    # sys_read
    ecall

    # - if read <= 0 break
    blez a0, read_done

    # - if buf[i] == '\n' break
    lb t2, 0(a1)
    li t3, 10
    beq t2, t3, read_done

    addi s0, s0, 1
    j read_loop

read_done:
    # buf[i] = '\0'
    la t1, buf
    add t1, t1, s0
    sb zero, 0(t1)

    # printf("|%s|\n", buf)
    la a0, fmt_str
    la a1, buf
    call printf

    # a = atoi(buf)
    la a0, buf
    call atoi
    mv s1, a0   # s1 = a

    # p = buf
    la s2, buf

find_space:
    lb t0, 0(s2)
    beqz t0, atoi_b # end string
    li t1, ' '
    beq t0, t1, skip_space
    addi s2, s2, 1
    j find_space

skip_space:
    addi s2, s2, 1

atoi_b:
    mv a0, s2
    call atoi
    mv s3, a0   # s3 = b

    # sum = a + b
    add s4, s1, s3

    # printf("%d\n", sum)
    la a0, fmt_num
    mv a1, s4
    call printf

    # exit(0)
    li a0, 0
    li a7, 2
    ecall
