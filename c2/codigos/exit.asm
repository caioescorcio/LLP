section .data
    code: db 1


section .text
global _start


exit:
    mov rax, 60
    syscall
    ret

_start:
    movzx rdi, byte [code] ; extende com 0 o valor em code
    call exit