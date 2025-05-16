; USANDO A MESMA BASE DE hello.asm

%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2
%define AT_FDCWD -100
%define STX_SIZE_OFFSET 0x30            ; Offset para o struct retornado pelo stat que indica o tamanho do arquivo


section .data
    fname: db 'c4/codigos/teste.txt', 0     ; file name
    stat_buff: times 256 db 0               ; reserva o espaço para o struct do stat
    newline_char: db 0xA, 0                 ; \n
    num_string: times 20 db 0               ; num_buff para imprimir inteiros

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




; STAT SYSCALL

    mov     rax, 262
    mov     rdi, AT_FDCWD           ; diretorio atual
    lea     rsi, fname              ; ponteiro para nome do arquivo
    lea     rdx, stat_buff          ; ponteiro para buffer struct stat
    mov     r10, 0                  ; flags
    syscall

    mov rdi, newline_char
    call print_string

    mov rdi, [stat_buff + STX_SIZE_OFFSET]  ; print apenas da parte do struct que contem o seu tamanho
    call print_uint


    mov rdi, newline_char
    call print_string



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


