global _start

section .text

_start: 
    mov rdi, 1  ; "false" no shell significa 1 
    mov rax, 60 
    syscall 