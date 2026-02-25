.data
fmt_nums: 
    .string "|%s|\n"
fmt_result:
    .string "%d\n"
msg_empty_input:
    .string "Empty input\n"
msg_nospace:
    .string "A space between two numbers is required\n"
msg_second_missed:
    .string "Second number is missing\n"

.text
.global main

main:
    addi sp, sp, -144
    sd ra, 136(sp)
    mv a0, sp
    li a1, 128
    call gets

delete_newline:
    mv t0, sp

newline_loop:
    lbu t1, 0(t0)
    beq t1, zero, end_line
    li t2, '\n'
    beq t1, t2, delete
    addi t0, t0, 1
    j newline_loop

delete:
    sb zero, 0(t0)

end_line:
    la a0, fmt_nums
    mv a1, sp
    call printf

search_for_first:
    mv t0, sp

first_num_loop:
    lbu t1, 0(t0)
    beq t1, zero, error_empty_input
    li t2, ' '
    bne t1, t2, find_first
    addi t0, t0, 1
    j first_num_loop

find_first:
    mv t3, t0
    addi t0, t0, 1

space_loop:
    lbu t1, 0(t0)
    beq t1, zero, error_nospace
    li t2, ' '
    beq t1, t2, find_space
    addi t0, t0, 1
    j space_loop

find_space:
    sb zero, 0(t0)
    addi t0, t0, 1

second_num_loop:
    lbu t1, 0(t0)
    beq t1, zero, error_second_missed
    li t2, ' '
    bne t1, t2, find_second
    addi t0, t0, 1
    j second_num_loop

find_second:
    mv t4, t0

result:
    mv a0, t3
    call atoi

    mv t3, a0

    mv a0, t4
    call atoi

    mv t4, a0

    add a1, t3, t4
    la a0, fmt_result
    call printf

    li a0, 0
    call exit

error_empty_input:
    li a0, 2
    la a1, msg_empty_input
    call fprintf
    li a0, 1
    call exit

error_nospace:
    li a0, 2
    la a1, msg_nospace
    call fprintf
    li a0, 1
    call exit

error_second_missed:
    li a0, 2
    la a1, msg_second_missed
    call fprintf
    li a0, 1
    call exit

