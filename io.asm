section .bss
    input resb 10 ; Buffer para entrada do usuário
    buffer resb 33 

section .data
		newline db 0xA  ; '\n'
		
section .text

scanf:
    ; Ler entrada do usuário
    mov eax, 3          ; syscall: read
    mov ebx, 0          ; file descriptor: stdin
    mov ecx, input      ; buffer para armazenar a entrada
    mov edx, 10         ; tamanho máximo da entrada
    int 0x80

    mov esi, input      ; Passa buffer para atoi
    call atoi
    ret                 ; Retorna com resultado em EAX

atoi:
    xor eax, eax        ; Zera EAX (acumulador)
    xor ecx, ecx        ; Zera ECX (contador)

atoi_loop:
    movzx ebx, byte [esi]  ; Pega caractere atual
    cmp ebx, 10            ; Se for '\n' (Enter), termina
    je atoi_done

    sub ebx, '0'           ; Converte ASCII para número
    imul eax, eax, 10      ; Multiplica acumulador por 10
    add eax, ebx           ; Adiciona novo dígito
    inc esi                ; Avança para próximo caractere
    jmp atoi_loop

atoi_done:
    ret                    ; Retorna com número em EAX

end_program:
    mov eax, 1          ; syscall: exit
    xor ebx, ebx        ; status de saída 0
    int 0x80
;;;;;;

print_bin:
    mov edi, buffer       ; Aponta para o buffer
    call bin_to_str       ; Converte EAX para string binária

    ; Exibir o resultado
    mov eax, 4           ; syscall: write
    mov ebx, 1           ; stdout
    mov ecx, buffer      ; Ponteiro para a string
    mov edx, 32         ; Tamanho da string
    int 0x80
	
	mov eax, 4
    mov ebx, 1
    mov ecx, newline  ; Agora ecx tem um ponteiro válido
    mov edx, 1
    int 0x80
	
    ret

; Converte EAX para uma string binária
bin_to_str:
    mov ecx, 32         ; Contador de bits
bin_loop:
    shl eax, 1          ; Move o bit mais significativo para CF
    mov byte [edi], '0' ; Define o caractere '0'
    adc byte [edi], 0   ; Adiciona 1 se CF estiver setado
    inc edi             ; Avança para o próximo caractere
    loop bin_loop       ; Repete para todos os 32 bits

    mov byte [edi], 0   ; Adiciona terminador nulo
    ret

;;;;;;;;;;;;;;
print_int:
    mov ecx, buffer + 11
    mov byte [ecx], 0  ; Termina a string com NULL
	

convert:
    dec ecx
    xor edx, edx
    mov ebx, 10
    div ebx            ; Divide eax por 10 (quociente em eax, resto em edx)
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz convert

    mov eax, 4      ; syscall: write
    mov ebx, 1      ; stdout
    mov edx, buffer + 11
    sub edx, ecx    ; Calcula o tamanho da string
    int 0x80
	
	mov eax, 4
    mov ebx, 1
    mov ecx, newline  ; Agora ecx tem um ponteiro válido
    mov edx, 1
    int 0x80
    ret
	
;;;;;;;;;
print_hex:
    mov edi, buffer + 8  ; Aponta para o final do buffer (8 caracteres)
    mov ecx, 8           ; Número de nibbles (cada byte tem 2 nibbles)
    
hex_loop:
    dec edi              ; Move para a posição correta
    mov dl, al           ; Pega os 4 bits menos significativos
    and dl, 0x0F         ; Isola o nibble
    add dl, '0'          ; Converte para caractere ASCII
    cmp dl, '9'          ; Se maior que '9', ajusta para 'A'-'F'
    jle skip_adjust
    add dl, 7
skip_adjust:
    mov [edi], dl        ; Armazena o caractere convertido
    shr eax, 4           ; Move para o próximo nibble
    loop hex_loop        ; Repete para todos os 8 nibbles

    ; Exibir o resultado
    mov eax, 4           ; syscall: write
    mov ebx, 1           ; stdout
    mov ecx, buffer      ; Ponteiro para a string
    mov edx, 8           ; Tamanho da string
    int 0x80
	
	mov eax, 4
    mov ebx, 1
    mov ecx, newline     ; Agora ecx tem um ponteiro válido
    mov edx, 1
    int 0x80
	
    ret