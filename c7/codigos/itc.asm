%include "lib.inc" ; que possui funções como print_string e read_word para call

global _start

; registradores Forth
%define pc r15
%define w r14
%define rstack r13

section .bss
resq 1023
rstack_start: resq 1
input_buff: resb 1024

; esta é a célula única que executa o programa

section .text
main_stub: dq xt_main

; O dicionário começa aqui. A primeira palavra é exibida de forma completa e, então, omitimos as flags
; e os links entre os nós por questão de consisão. Toda palavra armazena um endereço de sua implementação ASM

; Descarta o topo da pilha

dq 0 ; não há anterior
db "drop", 0
db 0; Flags = 0
xt_drop: dq i_drop  ; instrução i_drop
i_drop:             ; pula a instrução
    add rsp, 8
    jmp next

; Inicializa os registradores

xt_init: dq i_init
i_init: 
    mov rstack, rstack_start
    mov pc, main_stub
    jmp next

; Salva PC quando dois pontos começa
xt_docol: dq i_docol
i_docol:
    sub rstack, 8
    mov [rstack], pc
    add w, 8
    mov pc, w
    jmp next

; Retorna da palavra de dois-pontos
xt_exit: dq i_exit
i_exit:
    mov pc, [rstack]
    add rstack, 8
    jmp next

; Obtém um ponteiro de buffer da pilha,
; lê uma palavra da entrada e armazena começando no buffer especificado
xt_word: dq i_word
i_word:
    pop rdi
    call read_word
    push rdx
    jmp next

; Obtém um ponteiro de string da pilha e a exibe
xt_prints: dq i_prints
i_prints:
    pop rdi
    call print_string
    jmp next

; Sai do programa
xt_bye: dq i_bye
i_bye:
    mov rax, 60
    xor rdi, rdi
    syscall

; Carrega o endereço do buffer predefinido
xt_inbuf: dq i_inbuf
i_inbuf:
    push qword input_buff
    jmp next

; Esta é uma palavra de dois pontos, ela armazena toklens de execução em que cada um deles
; representa uma palavra Forth executada
xt_main: dq i_docol
    dq xt_inbuf
    dq xt_word
    dq xt_drop
    dq xt_inbuf
    dq xt_prints
    dq xt_bye

; O interpredator interno. Essas três linhas buscam a próxima instrução e dão início
; à sua execução
next: 
    mov w, [pc]
    add pc, 8
    jmp [w]

; O programa inicia sua execução a partir da palavra init
_start: jmp i_init

