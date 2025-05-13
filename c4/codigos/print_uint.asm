section .data
num_string: times 20 db 0   ; buffer para armazenar a string de numeros

section .text
global _start

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
    cmp byte [rdi+rax], 0   ; verifica se o RDI (inicio da string) com o offset (RAX) eh nulo
    jz .end                 ; se for, caractere \0 na string = fim
    inc rax                 ; se nao, aumenta-se o tamanho
    jmp .loop

    .end:
    ret                     ; retorna com o tamanho da string em RAX

; Em print_uint, temos que armazenar uma string com os números convertidos de cada operação para que ela seja printada por nosso print_string
; Para isso, fazemos uma reserva de 21 bytes em um buffer e lá armazenamos o que colocaremos para impressão.

; Iniciamos com RDI (nosso numero) em RAX. Colocamos o RSI para apontar para nosso buffer + 20 posicoes (num_string[19])
; Simulando nosso codigo:

; RAX = 123456, RSI => num_string[19] ==== div
; RDX = '6', num_string[19] = '6', RSI => num_string[18], num_string = '6'
; RDX = '5', num_string[18] = '5', RSI => num_string[17], num_string = '65'
; RDX = '4', num_string[17] = '4', RSI => num_string[16], num_string = '654'
; RDX = '3', num_string[16] = '3', RSI => num_string[15], num_string = '6543'
; RDX = '2', num_string[15] = '2', RSI => num_string[14], num_string = '65432'
; RDX = '1', num_string[14] = '1', RSI => num_string[13], num_string = '654321'
; print a partir de RSI+1, ou seja, de num_string[14] ate num_string[x] = 0


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

_start:

mov rdi, 123456
call print_uint

mov rax, 60                 ; fim   
xor rdi, rdi
syscall
