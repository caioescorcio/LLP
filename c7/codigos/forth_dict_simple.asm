section .data

w_plus:
    dq 0        ; ponteiro para a palavra anterior do dicionário (zero)
    db '+', 0   ; nome da palavra
    db 0        ; não há flags

xt_plus:        ; token de execução para 'plus' igual ao seu endereço de implementação
    dq plus_impl

w_dup:
    dq w_plus
    db 'dup', 0
    db 0

xt_dup:
    dq: dup_impl

w_sq:
    dq w_dup
    db 'sq', 0
    db 0
    dq docol    ; endereço de docol (nível de acesso indireto)
    dq xt_dup
    dq xt_plus
    dq xt_exit

last_word: dq w_sq

section .text

    plus_impl: 
        pop rax
        add rax, [rsp]
        mov [rsp], rax
        jmp next
    dup_impl:
        push qword [rsp]
        jmp next


