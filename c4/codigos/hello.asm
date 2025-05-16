; Antes dos dados, usaremos os nossos defines

%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2


section .data
fname: db 'c4/codigos/teste.txt', 0    ; file name

section .text
global _start

; PRINT STRING ROUTINE

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

_start:

; OPEN SYSCALL
mov rax, 2
mov rdi, fname
mov rsi, O_RDONLY           ; abre o arquivo somente para leitura
mov rdx, 0                  ; nao estamos criando um arquivo, logo eh um argumento sem sentido

syscall                     ; RAX agora possui o descritor do arquivo aberto (nome)

; MMAP SYSCALL

mov r8, rax                 ; R8 fica com o descritor antes em RAX
mov rax, 9                  ; MMAP
mov rdi, 0                  ; OS seleciona o local de armazenamento
mov rsi, 4096               ; 4KB de pagina
mov rdx, PROT_READ          ; a nova regiao criada sera de somente leitura
mov r10, MAP_PRIVATE        ; as paginas nao serao compartilhadas entre processos

mov r9, 0                   ; offset em teste.txt
syscall                     ; RAX agora tera o local mapeado

mov rdi, RAX                ; para printar o que foi mapeado
call print_string

mov rax, 60                 ; fim   
xor rdi, rdi
syscall


