read_char:
    push 0              ; reserva um byte no topo da pilha (sera usado como buffer)
    xor rax, rax        ; syscall 0 = read
    xor rdi, rdi        ; file descriptor 0 = stdin
    mov rsi, rsp        ; rsi aponta para o topo da pilha, onde vamos guardar 1 byte
    mov rdx, 1          ; vamos ler 1 byte
    syscall             ; faz a leitura
    pop rax             ; coloca o byte lido (em rsp) no registrador rax
    ret                 ; retorna com o caractere em AL (parte baixa de RAX)


section .text
global _start

read_word:
    push r14           ; salva registradores usados
    push r15
    xor r14, r14       ; r14 sera o contador de caracteres lidos
    mov r15, rsi       ; r15 = tamanho maximo do buffer
    dec r15            ; deixamos 1 byte para o terminador nulo

    .A:
    push rdi
    call read_char     ; le um caractere
    pop rdi
    cmp al, ' '        ; se for espaco
    je .A
    cmp al, 10         ; se for newline (\n)
    je .A
    cmp al, 13         ; se for carriage return (\r)
    je .A 
    cmp al, 9          ; se for tab
    je .A
    test al, al        ; se for NULL ou EOF
    jz .C              ; vai direto para finalizacao

    .B:
    mov byte [rdi + r14], al ; salva o caractere no buffer
    inc r14                  ; incrementa contador de caracteres

    push rdi
    call read_char           ; le o proximo caractere
    pop rdi
    cmp al, ' '
    je .C
    cmp al, 10
    je .C
    cmp al, 13
    je .C
    cmp al, 9
    je .C
    test al, al
    jz .C
    cmp r14, r15             ; se exceder limite do buffer
    je .D
    jmp .B

    .C:
    mov byte [rdi + r14], 0  ; adiciona '\0' no fim da palavra
    mov rax, rdi             ; retorna o endereco do buffer em rax
    mov rdx, r14             ; rdx = numero de caracteres lidos
    pop r15
    pop r14
    ret

    .D:
    xor rax, rax             ; retorna 0 para indicar erro
    pop r15
    pop r14
    ret


