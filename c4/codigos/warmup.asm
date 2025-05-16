section .text
    global _start

;------Não remova este arquivo-----
%include "io.asm" ; Implementação da leitura de valores inteiros e o print

_start:
    
    call scanf
    push rax
    call scanf
    push rax

    call scanf
    mov al, byte [esi-1]    ; após o atoi, o byte fica como seu inteiro correspondente caso ele seja número

    cmp al, '/'
    je .div

    cmp al, '+'
    je .add

    cmp al, '-'
    je .sub

    cmp al, '*'
    je .mul

    jmp .end

    .mul: 
        pop rax
        pop rbx
        mul rbx
        call print_bin
        jmp .end

    .add: 
        pop rax
        pop rbx
        add rax, rbx
        call print_bin
        jmp .end

    .sub: 
        pop rax
        pop rbx
        sub rax, rbx
        call print_bin
        jmp .end
        
    .div: 
        pop rax
        pop rbx
        cmp rbx, 0
        je .end
        xor rdx, rdx 
        div rbx
        call print_bin
        jmp .end

    .end:
    mov eax, 1          ; syscall: exit
    xor ebx, ebx        ; status de saída 0
    int 0x80