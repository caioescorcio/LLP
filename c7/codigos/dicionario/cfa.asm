global cfa

section .text

cfa:                            ; RAX conterá o início do cabeçalho da palavra no dicionário
;   Nossa estrutura é:
;   a: "A", 0
;      dq posicao_anterior
;      db 0                 ; flags 
;   xt_a:
;       ...
;

;   Logo, teremos, teoricamente, apenas que adicionar 1 byte ao registrador que conterá
;   o endereço do cabeçalho, para "pular" o byte de flags


    inc rax                     ; pula o byte de flags     
    .end:
        ret                     ; RAX apontará para o que está logo abaixo do código