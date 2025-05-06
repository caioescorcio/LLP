section .bss
    char resb 1         ; reserva 1 byte para o caractere lido

section .text
global _start

read_char:
    mov     rax, 0          ; syscall number for read
    mov     rdi, 0          ; stdin
    mov     rsi, char       ; endereço de armazenamento
    mov     rdx, 1          ; quantidade de bytes
    syscall

    mov     rax, 1          ; syscall number for write
    mov     rdi, 1          ; stdout
    mov     rsi, char       ; endereço do caractere
    mov     rdx, 1          ; 1 byte
    syscall
    ret

_start:

    call read_char
    mov     rax, 60         ; syscall exit
    xor     rdi, rdi
    syscall
