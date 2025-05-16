section .text
	global _start

%include "io.asm"

_start:
    
    call scanf
    mov rcx, rax    ; number of entries
    mov rbx, rax    ; 

    .data_loop:
    test rcx, rcx
    jz .print_loop
    push rcx
    push rbx
    call scanf
    pop rbx
    pop rcx
    push rax
    dec rcx
    jmp .data_loop




    .print_loop:
    test rbx, rbx
    jz .end
    pop rax
    push rbx
    call print_int
    pop rbx
    dec rbx
    jmp .print_loop

    .end:
    mov eax, 1          ; syscall: exit
    xor ebx, ebx        ; status de saída 0
    int 0x80