
    extern find_word
    extern cfa
    extern print_string
    extern print_newline
    extern print_char
    extern exit

    global _start

section .data
    test_word1 db "dup",0
    test_word2 db "-",0
    test_word3 db "NAOEXISTE",0
    msg_found db "Encontrada: ",0
    msg_notfound db "Nao encontrada",0
    msg_cfa db "CFA check",0

        ; Ponteiro para o início do dicionário
    pp: dq w_swap

    ; Entradas do dicionário:
    w_plus:
        dq 0              ; Link para a palavra anterior (nulo para a primeira palavra)
        db '+', 0         ; Nome da palavra
        db 0              ; Terminador nulo
    xt_plus:
        db 0

    w_minus:
        dq w_plus         ; Link para a palavra anterior
        db '-', 0         ; Nome da palavra
        db 0              ; Terminador nulo
    xt_minus:
        db 0

    w_dup:
        dq w_minus        ; Link para a palavra anterior
        db 'dup',0  ; Nome da palavra
        db 0              ; Terminador nulo
    xt_dup:
        db 0

    w_swap:
        dq w_dup          ; Link para a palavra anterior
        db 'swap',0  ; Nome da palavra
        db 0              ; Terminador nulo
    xt_swap:
        db 0

section .text
_start:
    ; Teste 1: Procurar DUP
    mov rdi, test_word1
    mov rsi, pp
    call find_word
    test rax, rax
    jz .notfound1

    mov rdi, msg_found
    call print_string
    mov rdi, test_word1
    call print_string
    call print_newline

    ; Testa cfa
    mov rdi, rax
    call cfa
    mov rdi, msg_cfa
    call print_string
    mov rdi, rax
    call print_char
    call print_newline
    jmp .test2

.notfound1:
    mov rdi, msg_notfound
    call print_string
    call print_newline

.test2:
    ; Teste 2: Procurar SWAP
    mov rdi, test_word2
    mov rsi, pp
    call find_word
    test rax, rax
    jz .notfound2

    mov rdi, msg_found
    call print_string
    mov rdi, test_word2
    call print_string
    call print_newline

    ; Testa cfa
    mov rdi, rax
    call cfa
    mov rdi, msg_cfa
    call print_string
    mov rdi, rax
    call print_char
    call print_newline
    jmp .test3

.notfound2:
    mov rdi, msg_notfound
    call print_string
    call print_newline

.test3:
    ; Teste 3: Procurar palavra inexistente
    mov rdi, test_word3
    mov rsi, pp
    call find_word
    test rax, rax
    jz .notfound3

    mov rdi, msg_found
    call print_string
    mov rdi, test_word3
    call print_string
    call print_newline

    ; Testa cfa
    mov rdi, rax
    call cfa
    mov rdi, msg_cfa
    call print_string
    mov rdi, rax
    call print_char
    call print_newline
    jmp .end

.notfound3:
    mov rdi, msg_notfound
    call print_string
    call print_newline

.end:
    call exit