%include "c4/codigos/utils.asm"     ; importa print_uint, string_length e print_string

%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2    

section .data
    fname: db 'c4/codigos/input.txt', 0                 
    newline_char: db 0xA, 0                 
    num_string: times 20 db 0, 0       
    pass_message: db 'PASS', 10, 0                      
    error_message: db 'ERRO', 10, 0                      

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


_start:

    call check_file_content
    call conv_char_to_number        ; converte o conteudo de RAX para um inteiro
    call operations
    call finaliza

