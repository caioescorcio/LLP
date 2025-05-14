%include "c4/codigos/utils.asm"     ; importa print_uint, string_length e print_string
%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2    

section .data
    fname: db 'c4/codigos/input.txt', 0                 
    newline_char: db 0xA, 0                 
    num_string: times 20 db 0, 0       
    pass_message: db ' PASS', 10, 0                      
    error_message: db ' ERRO', 10, 0     
    init_message: db 'Para X = ', 0
    factorial_message: db 'X! = ', 0    
    not_prime_message: db 'X não é primo', 0             
    prime_message: db 'X é primo', 0
    sum_message: db 'A soma dos digitos de X é: ', 0
    xth_fibo_message: db 'o X-ésimo número de Fibonacci é: ', 0
    not_fibo_message: db 'X não está em Fibonacci', 0             
    fibo_message: db 'X está em Fibonacci', 0

section .text
global _start

check_file_content:                         

    ; open + mmap para checkar o conteudo do arquivo
    ; open
    mov rax, 2
    mov rdi, fname
    mov rsi, O_RDONLY           
    mov rdx, 0                  
    syscall                     

    mov r8, rax                 
    mov rax, 9                  
    mov rdi, 0                  
    mov rsi, 4096               
    mov rdx, PROT_READ          
    mov r10, MAP_PRIVATE        
    mov r9, 0                   
    syscall                     

    ret                     ; return com RAX = ponteiro para a string do numero do arquivo


operations:

    push rax
    call factorial
    pop rax

    push rax
    call is_prime
    pop rax

    push rax
    call sum_digits
    pop rax
    
    push rax
    call xth_fibo
    pop rax

    push rax
    call is_fibo
    pop rax

    ret


factorial:      ; do X!
    xor rcx, rcx
    mov rbx, rax
    test rax, rax
    jz .end
    .loop:
    cmp rax, 1
    je .end
    dec rax
    xor rdx, rdx
    push rax
    mov rcx, rax
    mov rax, rbx
    mul rcx
    mov rbx, rax
    pop rax
    jmp .loop

    .end:
    push rbx
    mov rdi, factorial_message
    call print_string
    pop rbx
    mov rdi, rbx
    call print_uint
    mov rdi, newline_char
    call print_string
    ret

is_prime:       ; check if X is prime

    cmp rax, 1
    je .prime
    cmp rax, 2
    je .prime

    mov rcx, rax
    mov rbx, 2

    .loop:
    xor rdx, rdx
    cmp rbx, rcx
    je .prime
    push rax
    div rbx
    pop rax
    test rdx, rdx
    jz .not_prime
    inc rbx
    jmp .loop

    .prime:
    mov rdi, prime_message
    call print_string
    mov rdi, newline_char
    call print_string
    ret

    .not_prime:
    mov rdi, not_prime_message
    call print_string
    mov rdi, newline_char
    call print_string
    ret

sum_digits:     ; do the sum of the X's digits
    xor rcx, rcx
    mov r8, 10

    .loop:
    test rax, rax
    jz .end
    xor rdx, rdx
    div r8
    add rcx, rdx
    jmp .loop

    .end: 
    push rcx
    mov rdi, sum_message
    call print_string
    pop rcx
    mov rdi, rcx
    call print_uint
    mov rdi, newline_char
    call print_string
    ret

xth_fibo:       ; do util the Xth number on fibonacci
    xor rcx, rcx
    inc rcx
    xor rbx, rbx
    inc rbx

    .loop:
    cmp rax, 2
    jle .end
    mov rdx, rcx
    add rcx, rbx
    mov rbx, rdx
    dec rax
    jmp .loop

    .end:
    push rcx
    mov rdi, xth_fibo_message
    call print_string
    pop rcx
    mov rdi, rcx
    call print_uint
    mov rdi, newline_char
    call print_string
    ret

is_fibo:        ; check if X is on fibonacci 
    xor rcx, rcx
    inc rcx
    xor rbx, rbx
    inc rbx

    .loop_for_fibo:
    cmp rcx, rax
    je .fibo         
    cmp rcx, rax
    ja .not_fibo     

    mov rdx, rcx
    add rcx, rbx
    mov rbx, rdx

    jmp .loop_for_fibo


    .fibo:
    mov rdi, fibo_message
    call print_string
    mov rdi, newline_char
    call print_string
    ret

    .not_fibo:
    mov rdi, not_fibo_message
    call print_string
    mov rdi, newline_char
    call print_string
    ret


_start:

    call check_file_content
    call conv_char_to_number        ; converte o conteudo de RAX para um inteiro
    push rax

    push rax
    mov rdi, init_message
    call print_string
    pop rax

    mov rdi, rax
    call print_uint
    mov rdi, newline_char
    call print_string

    pop rax
    call operations
    call finaliza

