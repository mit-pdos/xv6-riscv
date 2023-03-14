#include "kernel/syscall.h"

.globl main
main:
	li a0, 1
	la a1, helloworld
	li a2, 14
	li a7, SYS_write
	ecall
	li a0, 0
	li a7, SYS_exit
	ecall

helloworld:
	.string "hello, world!\n"
