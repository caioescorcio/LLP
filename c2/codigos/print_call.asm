section .data

newline_char: db 10
codes: db '0123456789ABCDEF'

section .text
global _start

print_newline:

    mov rax, 1              ; para um syscall de stdout
    mov rdi, 1              ; para um destino de output (FD, arquivo) 1 (terminal)
    mov rdx, 1              ; para indicar que eh 1 caractere
    mov rsi, newline_char   ; para indicar a mensagem
    syscall
    ret

print_hex:

    mov rax, rdi            ; coloca rdi em rax, RDI sera o nosso arguemnto
    
    mov rdi, 1              ; para um destino de output (FD, arquivo) 1 (terminal)              
    mov rdx, 1              ; para indicar que eh 1 caractere
    mov rcx, 64             ; mesmo esquema de prin_rax.asm    
    
iterate:
    push rax                ; salva rax, pois o modificaremos no syscall
    sub rcx, 4              ; iteracao de 4 em 4 ate 64
    sar rax, cl             ; shift de rax em cl (60, 58...)
    and rax, 0xf            ; filtra apenas o ultimo caractere
    lea rsi, [codes + rax]  ; coloca em rsi ("ponteiro de print") o que representaria, o offset de codes em caracteres

    mov rax, 1              ; stdout

    push rcx                ; syscall altera rcx, devemos salva-lo  
    syscall                 ; rax = 1 (31, identificador de write)
                            ; rdi = 1 (stdout)
                            ; rsi = endereco do caractere (codes + offset)
    pop rcx
    pop rax
    test rcx, rcx
    jnz iterate             ; recuperacao de valores + loop

    ret

_start:
    call print_newline      ; nao esqueca que print_newline modifica rdi
    mov rdi, 0xCA10E5C04C10
    call print_hex
    call print_newline
    call print_newline

    mov rax, 60
    xor rdi, rdi
    syscall


