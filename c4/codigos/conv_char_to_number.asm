section .data
    str_num:    db "123", 0       ; a string que vamos converter

section .text
global _start


conv_char_to_number:    ; converte um char para um inteiro
    mov rdi, rax 

    mov r8, 10       
    xor rax, rax
    xor rcx, rcx    
    
    .loop:
    movzx r9, byte [rdi + rcx]      ; le o byte atual da string e coloca em r9 (zero-ext)
    test    r9b, r9b              ; se for zero (fim de string), sai
    je      .end
    cmp r9b, '0'                    ; se caractere < '0', nao e numero
    jb .end
    cmp r9b, '9'                    ; se caractere > '9', nao e numero, r9b ~ r9 last byte
    ja .end

    xor rdx, rdx                    ; para limpar a operacao 'mul'
    mul r8                          ; RAX *= 10

    sub r9b, '0'                    ; separa o caractere (byte em r9) da sua string
    add rax, r9                     ; adiciona ao RAX

    inc rcx
    jmp .loop


    .end: 
    ret                             ; rax com o numero

_start:
    lea     rax, str_num    ; passa ao conv_char_to_number um ponteiro para "123"
    call    conv_char_to_number   ; RAX  123

    ; aqui você pode usar RAX (por exemplo, imprimir ou usar como código de saída)
    mov     rdi, rax              ; código de saída = valor convertido
    mov     rax, 60               ; syscall: exit
    syscall