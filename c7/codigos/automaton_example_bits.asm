section .text

; getsymbol é uma rotina para let um símbolo (ex: stdin) em AL (de RAX)

_A: 
    call getsymbol
    cmp al, '+'
    je _B
    cmp al, '-'
    je _B

    cmp al, '0'
    jb _E
    cmp al, '9'
    ja _E
    jmp _C

_B: 
    call getsymbol
    cmp al, '0'
    jb _E
    cmp al, '9'
    ja _E
    jmp _C

_C:

    call getsymbol
    cmp al, '0'
    jb _E
    cmp al, '9'
    ja _E
    test al, al
    jz _D
    jmp _C

_D: 
    ; rotina de tratamento de sucesso

_E:
    ; rotina de tratamento de erros

