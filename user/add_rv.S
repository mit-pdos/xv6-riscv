#define BUF_SIZE 128

.data
prompt:       .asciz "Enter two numbers separated by space: "
format_str:   .asciz "|%s|\n"
result_fmt:   .asciz "Sum: %d + %d = %d\n"
error_input:  .asciz "Error: input failed\n"
error_empty:  .asciz "Error: empty input\n"
error_space:  .asciz "Error: space separator not found\n"
error_number: .asciz "Error: invalid number format\n"
error_long:   .asciz "Error: input too long\n"

.bss
buffer:       .space BUF_SIZE
num1:         .space 4
num2:         .space 4

.text
.global main



is_number:
    # Если первый символ '+' или '-'
    lbu t0, 0(a0)
    li t1, '-'
    beq t0, t1, 1f
    li t1, '+'
    beq t0, t1, 1f
    j 2f
    
1:
    # Пропускаем символ
    addi a0, a0, 1
    lbu t0, 0(a0)
    
2:
    # Если конец строки, то это не число
    beqz t0, 4f
    
3:
    # Проверка циферок
    lbu t0, 0(a0)
    beqz t0, 5f
    li t1, '0'
    blt t0, t1, 4f
    li t1, '9'
    bgt t0, t1, 4f
    addi a0, a0, 1
    j 3b
    
4:
    # не число
    li a0, 0
    ret
    
5:
    # число
    li a0, 1
    ret

main:
    # Сохраняем ra, s0, s1, s2 на стеке
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)
    
    # Выводим сообщение через printf
    la a0, prompt
    call printf
    
    # Читаем строку с клавы через gets
    la a0, buffer
    li a1, BUF_SIZE
    call gets
    
    # Проверяем результат gets
    bnez a0, 1f
    
    # Если ошибка ввода
    la a0, error_input
    call printf
    li a0, 1
    j exit
    
1:
    # Проверка на переполнение буфера
    la t0, buffer
    li t1, BUF_SIZE
    add t1, t0, t1
    addi t1, t1, -1
    
    # Проверка на \n
    lbu t2, 0(t1)
    li t3, '\n'
    beq t2, t3, 2f
    
    # Проверка на \0 (т.е. переполнение)
    addi t1, t1, -1
    lbu t2, 0(t1)
    bnez t2, long_input
    
2:
    # Удаляем символ новой строки из буфера, если он есть
    la s0, buffer
    li s1, '\n'
    
remove_newline:
    lbu t0, 0(s0)
    beqz t0, 3f
    beq t0, s1, found_newline
    addi s0, s0, 1
    j remove_newline
    
found_newline:
    sb zero, 0(s0)
    
3:
    # Выводим прочитанную строку в ограничителях для отладки
    la a0, format_str
    la a1, buffer
    call printf
    
    # Проверяем, что строка не пустая
    la t0, buffer
    lbu t1, 0(t0)
    bnez t1, 4f
    
    # Пустая строка
    la a0, error_empty
    call printf
    li a0, 1
    j exit
    
4:
    # Парсим строку: ищем пробел
    la s0, buffer
    li s2, ' '
    mv s1, s0
    
find_space:
    lbu t0, 0(s1)
    beqz t0, no_space_found
    beq t0, s2, space_found
    addi s1, s1, 1
    j find_space
    
no_space_found:
    la a0, error_space
    call printf
    li a0, 1
    j exit
    
space_found:
    # Заменяем пробел на 0
    sb zero, 0(s1)
    addi s1, s1, 1
    
    # Проверяем, что первая часть - число
    mv a0, s0
    call is_number
    beqz a0, invalid_number
    
    # Проверяем, что вторая часть - число
    mv a0, s1
    call is_number
    beqz a0, invalid_number
    
    # Парсим первое число
    mv a0, s0
    call atoi
    la t1, num1
    sw a0, 0(t1)
    
    # Парсим второе число
    mv a0, s1
    call atoi
    la t1, num2
    sw a0, 0(t1)
    
    # Вызываем системный вызов add
    la t1, num1
    lw a0, 0(t1)
    la t1, num2
    lw a1, 0(t1)
    
    # Сохраняем числа на стеке
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    li a7, 22
    ecall
    
    # Результат в a0 - сумма
    mv t2, a0
    
    # Восстанавливаем числа для вывода
    lw a1, 0(sp)
    lw a2, 4(sp)
    mv a3, t2
    
    # Выводим результат
    la a0, result_fmt
    call printf
    
    # Успешное завершение
    li a0, 0
    j exit
    
invalid_number:
    # Ошибка формата числа
    la a0, error_number
    call printf
    li a0, 1
    j exit
    
long_input:
    # Ошибка переполнения буфера
    la a0, error_long
    call printf
    li a0, 1
    j exit
    
exit:
    # Восстанавливаем регистры
    ld s2, 0(sp)
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    
    # Выход через системный вызов exit
    li a7, 2
    ecall
