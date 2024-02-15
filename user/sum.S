.section .text
.globl _start

_start:
    la a0, buffer      
    li a1, 100         
    call gets          

    lb t0, 0(buffer)
    beq t0, zero, error_empty_string

    la a0, buffer      
    call atoi          

    li t1, -1          
    beq a0, t1, error_conversion

    move t0, a0       

    la a0, buffer      
    call find_space    
    beqz a0, error_format 

    call atoi         

    beq a0, t1, error_conversion

    move t1, a0        

    add a0, t0, t1    

    la a0, fmt         
    call printf        

    li a0, 0           
    call exit          

find_space:
    li t2, 32

find_space_loop:
    lb t3, 0(a0)
    beq t3, zero, find_space_end 
    beq t3, t2, find_space_found 
    addiu a0, a0, 1    
    j find_space_loop

find_space_end:
    li a0, 0           
    jr ra

find_space_found:
    addiu a0, a0, 1
    jr ra

error_empty_string:
    la a0, err_empty   
    call printf
    j exit_program

error_conversion:
    la a0, err_conv    
    call printf
    j exit_program

error_format:
    la a0, err_format  
    call printf
    j exit_program

exit_program:
    li a0, 1           
    call exit

.section .data
buffer:
    .space 100         

fmt:
    .string "Сумма: %d\n" 

err_empty:
    .string "Ошибка: Пустая строка\n"

err_conv:
    .string "Ошибка: Некорректное число\n"

err_format:
    .string "Ошибка: Неверный формат данных. Ожидалось два числа, разделенных пробелом.\n"


	
