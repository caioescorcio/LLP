section .data
    test_word1 db "+", 0
    test_word2 db "-", 0
    test_word3 db "NAOEXISTE", 0
    msg_found  db "Encontrada: ", 0
    msg_notfound db "Nao encontrada", 0
    msg_cfa    db "CFA: ", 0

; Cada registro terá 16 bytes, onde:
; • Os primeiros 8 bytes são o link para o registro anterior (deve apontar para o campo "nome" do registro anterior).
; • Os próximos 8 bytes contêm a string (zero-terminada e preenchida com zeros caso necessário).
w_plus:
    dq 0              ; Nenhum registro anterior
    db '+', 0       
    db 0      ; Preenche para 8 bytes de área do "nome"

w_minus:
    dq w_plus      ; Link aponta para o campo "nome" de w_plus
    db '-', 0       
    db 0

w_mult:
    dq w_minus    ; Link aponta para o campo "nome" de w_minus
    db 'x', 0       
    db 0