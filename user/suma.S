#define BUF_SIZE 10
#define STDERR_D 2
#define MAX_LEN_OF_FIRST_DIGIT BUF_SIZE-2

.data

buffer: .space BUF_SIZE
sum_result_string: .asciz "%d\n"
sum_exception_msg: .asciz "Not enough / invalid arguments.\n"

.text
.global main

# Вот прям по минимуму обработку оставил, как и обговаривали
main:
    la a0, buffer # char* a0 = buffer
    li a1, BUF_SIZE # int a1 = BUF_SIZE
    call gets # gets(a0, a1) -> buffer в a0

    li t4, ' ' # int my_const = ' '
    li t5, MAX_LEN_OF_FIRST_DIGIT # int max_len_of_first_digit = MAX_LEN_OF_FIRST_DIGIT - Т.к. плохой случай может иметь вид: {'a', 'b', 'c', ' ', '\0'}, где BUF_SIZE = 5

    addi t0, zero, 0 # int space_ind = 0
    mv t1, a0 # char* t1 = a0 - указывают на одно и то же

while_body:
    lb t2, 0(t1) # char t2 = *t1 - разыменование указателя (char весит 1 байтик)
    beq t4, t2, while_done # if buffer[space_ind] == ' ' then goto while_done

    bge t0, t5, sum_exception # Если плохой случай

    addi t1, t1, 1 # t1++ - проходим на след элемент buffer (согласно арифметике указателей)
    addi t0, t0, 1 # space_ind++

    j while_body

while_done:
    li t4, 0 # int t4 = '\0'
    sb t4, 0(t1) # (t1 =) buffer[space_ind] = '\0' (= t4)

    sub a0, t1, t0 # t1 = начало buffer
    call atoi

    mv t2, a0 # t2 = atoi(buffer)

    addi a0, t1, 1 # a0 = buffer + space_ind + 1
    call atoi

    add a1, t2, a0 # a1 = atoi(buffer) + atoi(buffer + space_ind + 1)
    la a0, sum_result_string

    call printf

    li a7, 2                  # Exit system call
    li a0, 0                  # Exit status (success)
    ecall

sum_exception:
    la a0, STDERR_D
    la a1, sum_exception_msg
    call fprintf

    li a7, 2                  # Exit system call
    li a0, 1                  # Exit status (failure)
    ecall                     # Syscall