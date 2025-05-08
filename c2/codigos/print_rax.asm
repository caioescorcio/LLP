section .data

codes:
    db  '0123456789ABCDEF'

section .text
global _start

_start:
    ; numero 1122... em hexadecimal
    mov rax, 0x1122334455667788 ; = 0001 0001 0010 0010 ... 1000 1000  

    mov rdi, 1   ; File descriptor 1 (stdout) para saida
    mov rdx, 1   ; Numero de bytes a escrever (cada caractere hexadecimal)
    mov rcx, 64  ; 64 bits no numero, usado para deslocamento

    ; 4 bits representam um dígito hexadecimal
    ; Use o descolamento (shift) e o AND lógico para isola-los
    ; O resultado desse AND é o 'offset' no array '.codes'

.loop:

    push rax                ; "aumenta" a fila e coloca o valor do ponteiro de RAX no topo da fila para pega-lo depois que fizermos cada iteracao no loop
    sub rcx, 4              ; subtrai rcx em 4. RCX só será zero se o loop for perpassado 16x (64 - 4x16 = 0)
    ; cl eh a parte menor do reg rcx: 
    ; rcx -- ecx -- cx -- ch + cl, cl sao os ultimos 8 bits de rcx, no caso, 64, 60, 58, ... a cada iteracao

    sar rax, cl             ; sar = shift arithmetic right - preserva o sinal, shifta RAX em cl
    and rax, 0xF            ; pega os ultimos 4 bits (pois 0xF = 1111) de rax. Isso faz com que passemos a cada caractere

    lea rsi, [codes + rax]  ; lea = LOAD EFFECTIVE ADDRESS, coloca em RSI o que a posição de 'codes' + a posição do que está em rax
                            ; nesse caso, se rax = 0010, teremos em RSI o ponteiro do inicio do array 'codes' + 2, representando o caractere '2'
    mov rax, 1              ; syscall de write

    ; syscall altera rcx e r11
    
    ; syscall altera RCX e R11, entao salvamos RCX temporariamente
    push rcx      
    syscall       ; Chamada de sistema: write(1, &char, 1)
    pop rcx       ; Restauramos RCX apos a syscall

    pop rax       ; recuperamos o RAX

    ; 'test' pode ser usado cono una verificacao rapida de se um numero eh 0
    
    test rcx, rcx   ; checamos se RCX chegou a 0
    jnz .loop       ; se nao, loop

    mov rax, 60
    xor rdi, rdi    ; finalizamos o programa
    syscall