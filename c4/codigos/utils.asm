%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2
%define AT_FDCWD -100
%define STX_SIZE_OFFSET 0x30 

print_string:
    push rdi                ; salvamos RDI para que ele va para o RSI posteriormente
    call string_length      ; com o inicio da string em RDI e com o tamanho em RAX, podemos printar uma string
    pop rsi                 ; colocamos RDI, antes pushado, agora em RSI
    mov rdx, rax            ; RAX em RDX para o seu tamanho
    mov rax, 1              ; syscall de print_string (write)
    mov rdi, 1              ; 1 para dispositivo de stdout
    syscall
    ret

string_length:
    xor rax, rax            ; RAX = 0

    .loop:                  ; inicio do loop
    cmp byte [rdi+rax], 0        ; verifica se o RDI (inicio da string) com o offset (RAX) eh nulo
    jz .end                 ; se for, caractere \0 na string = fim
    inc rax                 ; se nao, aumenta-se o tamanho
    jmp .loop

    .end:
    ret                     ; retorna com o tamanho da string em RAX


print_uint:                 ; recebe em RDI o inicio do numero
    mov rax, rdi            ; RAX < RDI
    mov r8, 10
    lea rsi, [num_string + 20];      

    
    .loop:                  
    xor rdx, rdx                    ; RDX = 0
    div r8                          ; RAX = RAX/10, RDX = RAX%10
    or dl, 0x30                     ; character 0 para formar uma string de numero
    mov [rsi], dl                   ; coloca em RSI o byte
    dec rsi                         ; RSI = RSI - 1
    test rax, rax                   ; verifica se RAX eh nulo
    jnz .loop                       ; se ainda ha RAX, volta para o loop
    inc rsi
    mov rdi, rsi
    call print_string
    ret

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



finaliza:

    mov rax, 60
    xor rdi, rdi
    syscall
