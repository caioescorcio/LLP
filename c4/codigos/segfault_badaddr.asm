section .data
correct: dq -1

section .text
global _start
start:

mov rax, [0x00400000-1]

mov rax, 60
xor rdi, rdi
syscall

