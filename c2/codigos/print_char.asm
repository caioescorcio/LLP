section .data
    code: db 0x68


section .text
global _start


print_char:
    mov r9, rdi             ; salva o argumento
    mov rax, 1              ; para um syscall de stdout
    mov rdi, 1              ; para um destino de output (FD, arquivo) 1 (terminal)
    mov rdx, 1              ; para indicar que eh 1 caractere
    mov rsi, r9             ; para indicar a mensagem
    mov rdx, 1              ; tamanho: 1 byte
    syscall
    ret


_start:
    lea rdi, [code]         ; load no endereço de code
    call print_char


    mov rax, 60
    xor rdi, rdi                ; codigo de saida 0
    syscall
