section .data
    buffer: times 20 db 0     ; espaco para ate 20 digitos (uint64_t pode ter ate 20 digitos)
    menos: db 0x2D

section .text
global _start

print_int:
    ; Entrada: rdi = numero
    mov rax, rdi                ; copia numero para rax (vamos trabalhar com ele)
    test rax, rax               ; verifica se o numero eh negativo
    jns .positivo
    neg rdi                         ; rdi = -rdi (tornando o numero positivo)
    mov r10, rdi
    lea rdi, [menos]
    call print_char
    mov rdi, r10
    lea rsi, [rel buffer + 18]  
    mov rcx, 10 
    mov rax, rdi
    jmp .convert_loop

.positivo:
    lea rsi, [rel buffer + 20]  ; ponteiro para o fim do buffer: rsi comeca com o endereco do buffer + 20
    mov rcx, 10                 ; divisor

.convert_loop:
    xor rdx, rdx              ; limpa rdx antes da divisao
    div rcx                   ; rax / 10, rax = quociente, rdx = resto
    dec rsi                   ; anda uma posicao para tras no buffer (rsi = rsi - 1)
    add dl, '0'               ; converte digito para ASCII
    mov [rsi], dl             ; salva caractere em rsi na posicao shiftada
    test rax, rax             ; ainda ha digitos?
    jnz .convert_loop

.print:
    mov rdx, buffer + 20
    sub rdx, rsi              ; tamanho da string = total - posicao atual
    mov rax, 1                ; syscall write
    mov rdi, 1                ; stdout
    mov rsi, rsi              ; ponteiro para string (ja esta em rsi)
    syscall
    ret

_start:
    mov rdi, 1234567890       ; numero a imprimir
    call print_int

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall

print_char:
    mov r9, rdi             ; salva o argumento
    mov rax, 1              ; para um syscall de stdout
    mov rdi, 1              ; para um destino de output (FD, arquivo) 1 (terminal)
    mov rdx, 1              ; para indicar que eh 1 caractere
    mov rsi, r9             ; para indicar a mensagem
    mov rdx, 1              ; tamanho: 1 byte
    syscall
    ret


