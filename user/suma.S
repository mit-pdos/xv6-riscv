#define BUF_SIZE 20
#define STDERR_D 2
#define MAX_LEN_OF_FIRST_DIGIT BUF_SIZE-2

.data

buffer: .space BUF_SIZE
a: .space BUF_SIZE
b: .space BUF_SIZE

sum_result_string: .asciz "%d\n"
sum_exception_msg: .asciz "Error!\n"

.text
.global main

main:
    la a0, buffer # char* a0 = buffer
    li a1, BUF_SIZE # int a1 = BUF_SIZE
    call gets # gets(a0, a1) -> buffer в a0

    li t4, ' ' # int my_const = ' '
    li t5, MAX_LEN_OF_FIRST_DIGIT # int max_len_of_first_digit = MAX_LEN_OF_FIRST_DIGIT

    addi t0, zero, 0 # int space_ind = 0
    mv t1, a0 # char* t1 = a0 - указывают на одно и то же

    la t3, a # char* t3 = a

while_body:
    lb t2, 0(t1) # char t2 = *t1 - разыменование указателя (char весит 1 байтик)
    beq t4, t2, while_done # if buffer[space_ind] == ' ' then goto while_done

    bge t0, t5, sum_exception

    sb t2, 0(t3) # t3 = a[space_ind] = buffer[space_ind] = t2

    addi t1, t1, 1 # t1++ - проходим на след элемент buffer (согласно арифметике указателей)
    addi t3, t3, 1 # t3++ - проходим на след элемент a (согласно арифметике указателей)

    addi t0, t0, 1 # space_ind++
    j while_body

while_done:
    li t4, 0 # int t4 = '\0'
    sb t4, 0(t3) # (t3 =) a[space_ind] = '\0' (= t4)

    # Обработка второго числа
    la a0, b # char* a0 = b
    addi a1, t1, 1
    call strcpy
    # --------------------

    call atoi # a0 = atoi(указатель на начало b)
    mv t1, a0 # t1 = a0

    sub t3, t3, t0 # ушли в начало a (a_pointer - space_ind)
    mv a0, t3 # a0 = t3
    call atoi # a0 = atoi(указатель на начало a)

    add a1, t1, a0 # a1 = t1 + a0 = atoi(указатель на начало b) + atoi(указатель на начало a)
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