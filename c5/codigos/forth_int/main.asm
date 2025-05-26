section .text
%include "colon.inc"

extern read_word
extern find_word
extern print_newline
extern print_string
extern print_error
extern string_length
extern exit

global _start

section .bss
input resb 255

section .rodata
msg_noword: db "Não achada", 0
err_read: db 'Erro ao ler', 0

%include "words.inc"
    
section .text

_start:
    mov     rdi, input      ; endereço do buffer
    mov     rsi, 255        ; tamanho máximo do buffer
    call    read_word       ; lê o buffer e coloca em "input"

    mov     rdi, input      ; buffer com a palavra lida
    mov     rsi, pp         ; ponteiro do dicionário (pp foi definido no nosso macro)
    call    find_word       ; procura a entrada do dicionario correspondente

    test    rax, rax
    jz      .no_find        ; caso a entrada seja nula, não achou
                            ; caso contrário, RAX está apontando para o inicio do struct:

                            ; colon {
                            ;   *prev_position - 8 bytes
                            ;   string name
                            ;  }
                            ;   
                            ;   ** Outros códigos abaixo **
                            ;
                            ;

                            ; logo, o raciocínio é, agora com o ponteiro para o "prev_position", acharmos o final da string "name" para que 
                            ; possamos acessar o código após ela

    add     rax, 8          ; ajusta para pular o cabeçalho do dicionário (onde está o início da string name)
    mov     rdi, rax        ; rdi = endereço do nome
    call    string_length   ; acha o tamanho do nome para que o RDI aponte para o final da struct
    add     rdi, rax        ; rdi = colon[final]
    inc rdi                 ; rdi = colon[final + 1] = OUTROS CÓDIGOS - poderiamos colocar RIP apontando para ele, por exemplo
    call    print_string    ; printamos o que está abaixo do cólon
    jmp     .end

.no_find:
    mov     rdi, msg_noword
    call    print_string

.end:
    call    exit