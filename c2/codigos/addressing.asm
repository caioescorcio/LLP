section .data
    test: dq -1  ; Definimos um valor inicial de teste
    codes: db '0123456789ABCDEF' 

section .text
global _start

_start:
    mov byte[test], 1
    ;mov word[test], 1
    ;mov dword[test], 1
    ;mov qword[test], 1

    mov rax, [test]    

    ; Trecho reciclado de print_rax.asm

    mov rdi, 1 
    mov rdx, 1  
    mov rcx, 64 

.loop:
    push rax        
    sub rcx, 4      

    shr rax, cl     
    and rax, 0xF    

    lea rsi, [codes + rax] 

    mov rax, 1      
    push rcx        
    syscall         
    pop rcx         

    pop rax         

    test rcx, rcx   
    jnz .loop       

    
    mov rax, 60     
    xor rdi, rdi
    syscall
