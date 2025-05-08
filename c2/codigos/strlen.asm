global _start

section .data

test_string: db "abcdefh", 0    ; A string deve terminar em 0 para que saibamos onde acaba o seu conteudo


section .text

strlen:             ; Por convencao, o primeiro e unico argumento a ser passado eh obtido por RDI

    xor rax, rax    ; RAX armazenara o tamanho da string. Se nao for zerado antes, seu valor 
                    ; sera aleatorio, por isso eh feito esse XOR

.loop:              ; Loop de execucao

    cmp byte [rdi+rax], 0   ; Verifica se, somado ao tamanho 'atual' medido da string, o byte visto 
                            ; a partir da posicao RDI eh nulo (EOL)

    je .end                 ; Se forem iguais, trata-se usando a funcao END 
    inc rax                 ; Se nao, incremento de RAX (funcao inc eh increment: RAX += 1)

    jmp .loop               ; Jump incondicional

.end:

    ret                     ; Quando 'ret'eh chamado, rax tera o valor de retorno

_start:

    mov rdi, test_string    ; RDI eh colocado como inicio da string de teste
    call strlen             ; Chama a funcao (note que nao usamos a pilha para isso)
    mov rdi, rax            ; RDI deixa de ser o valor visto pela string e passa a ser o argumento para o syscall

    mov rax, 60             ; syscall para finalizar
    syscall