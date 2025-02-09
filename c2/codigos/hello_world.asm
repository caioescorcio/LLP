global _start

section .data
message: db 'hello, world!', 10

section .text
_start:
    mov rax, 1;
    mov rdi, 1;
    mov rsi, message;
    mov rdx, 14
    syscall;

; Encerra o programa corretamente
    mov rax, 60         ; syscall: sys_exit (60)
    xor rdi, rdi        ; Código de saída 0
    syscall             ; Chama o kernel para sair