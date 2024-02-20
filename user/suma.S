#define BUF_SIZE 20

.data

buffer: .space BUF_SIZE
a: .space BUF_SIZE
b: .space BUF_SIZE

format_d_string: .asciz "%d\n"

.text
.global main

main:
    la a0, buffer # char* a0 = buffer
    li a1, BUF_SIZE # int a1 = BUF_SIZE
    call gets # gets(a0, a1) -> buffer в a0

    li s0, ' ' # int my_const = ' '

    addi t0, zero, 0 # int space_ind = 0
    mv t1, a0 # char* t1 = a0 - указывают на одно и то же

    la t3, a # char* t3 = a

while_body:
    lb t2, 0(t1) # char t2 = *t1 - разыменование указателя (char весит 1 байтик)
    beq s0, t2, while_done # if buffer[space_ind] == ' ' then goto while_done

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
    la a0, format_d_string

    call printf

    li a7, 2                  # Exit system call
    li a0, 0                  # Exit status (success)
    ecall
