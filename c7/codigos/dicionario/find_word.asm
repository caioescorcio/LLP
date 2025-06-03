global find_word
extern string_equals

section .rodata
msg_noword: db "No such word",0

section .text
find_word:                          ; RDI conterá o início da string e RSI conterá a entrada do dicionario

    xor rax, rax                    ; zera rax
    .loop:
        test rsi, rsi                   ; se RSI for nulo (primeira entrada) não há como buscar no dicionario
        jz .end
        push rdi                        ; salva RDI e RSI
        push rsi
        add rsi, 8                      ; agora RSI aponta para 8 posições na frente pois nossa estrutura é do estilo:

        ;   dq anterior: XXXX   ; como é uma quadword (dq), ao adicionar 8 ao RSI, apontaremos para o "nome" no inicio da string
        ;   db "nome", 0

        call string_equals      ; chama string_equals para comparar as strings
        pop rsi                 ; recupera RSI e RDI
        pop rdi                 
        test rax, rax           ; verifica se string_equals deu que são iguais
        jnz .found              ; se forem, vai para .found
        mov rsi, [rsi]          ; caso contrário, RSI agora vai apontar para o que está no início do conteúdo de rsi [RSI + 0] que é justamente a posição anterior da memória

        ;   dq anterior: XXXX   ; RSI[0] = === [RSI] = XXXX é o a posição de memória anterior
        ;   db "nome", 0

        jmp .loop
    
    .found:
        mov rax, rsi            ; retorna a posição no dicionário

    .end:
        ret


