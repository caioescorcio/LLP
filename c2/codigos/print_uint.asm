section .data
    buffer: times 20 db 0     ; espaco para ate 20 digitos (uint64_t pode ter ate 20 digitos)

section .text
global _start

print_uint:
    ; Entrada: rdi = numero
    mov rax, rdi              ; copia numero para rax (vamos trabalhar com ele)
    lea rsi, [rel buffer + 20]; ponteiro para o fim do buffer: rsi comeca com o endereco do buffer + 20
    mov rcx, 10               ; divisor

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
    call print_uint

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall
