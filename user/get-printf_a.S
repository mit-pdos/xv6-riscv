#define BUFFER_LEN 512

//считаем аргументы четко по колво пробелов
.data
        print: .asciz "%d\n"
        error_null_: .asciz "ERROR: the number of arguments is less than two\n"
        error_read_: .asciz "ERROR: problems with reading\n"
        error_more_: .asciz "ERROR: the number of arguments is more than two\n"
        error_not_integer: .asciz "ERROR: the arguments are not integer\n";

buffer: .byte BUFFER_LEN

.text
.global main

main:
la a0, buffer
li a1, BUFFER_LEN
call gets
beq a0, zero, error_read

la t0, buffer
li a1, ' '
call strchr

beqz a0, error_null
mv t1, a0
addi a0, a0, 1
call strchr

beq a0, zero, search_sum

j error_more

error_null:
    li a7, 16
    li a0, 2
    la a1, error_null_
    li a2, 48
    ecall
    li a7, 2
    li a0, 1
    ecall

error_read:
    li a7, 16
    li a0, 2
    la a1, error_read_
    li a2, 29
    ecall
    li a7, 2
    li a0, 1
    ecall

error_more:
    li a7, 16
    li a0, 2
    la a1, error_more_
    li a2, 48
    ecall
    li a7, 2
    li a0, 1
    ecall

search_sum:
    sb zero, 0(t1)
    la a0, buffer
    call atoi
    mv t2, a0
    addi t1, t1, 1
    mv a0, t1
    call atoi
    mv t3, a0

    add t4, t2, t3
    la a0, print
    mv a1, t4
    call printf
    li a7, 2
    li a0, 0
    ecall


