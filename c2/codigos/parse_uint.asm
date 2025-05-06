parse_uint:
    mov r8, 10         ; r8 = base decimal (10)
    xor rax, rax       ; rax = acumulador do resultado final (zera)
    xor rcx, rcx       ; rcx = indice do caractere atual na string (zera)

.loop:
    movzx r9, byte [rdi + rcx] ; le o byte atual da string e coloca em r9 (zero-ext)

    cmp r9b, '0'       ; se caractere < '0', nao e numero
    jb .end
    cmp r9b, '9'       ; se caractere > '9', nao e numero
    ja .end

    xor rdx, rdx       ; limpa rdx (obrigatorio antes de 'mul' para evitar lixo)
    mul r8             ; rax *= 10

    and r9b, 0x0F      ; converte caractere ASCII para numero (ex: '5' -> 5)
    add rax, r9        ; adiciona o novo digito ao acumulador

    inc rcx            ; avanca para o proximo caractere
    jmp .loop          ; repete o processo

    .end:
    mov rdx, rcx       ; guarda em rdx quantos caracteres validos foram lidos
    ret

section .data
    input db '12345abc', 0

section .text
global _start

_start:
    lea rdi, [rel input]
    call parse_uint

    ; rax agora tem 12345
    ; rdx tem 5 (numero de caracteres lidos)

    ; finalizar programa
    mov rax, 60
    xor rdi, rdi
    syscall
