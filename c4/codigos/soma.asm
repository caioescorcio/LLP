
%include "io.asm"

section .data

section .bss
	v resd 20
	
section .text
	global _start


_start:
    
    call scanf
    mov rcx, rax    ; number of entries
    mov rbx, rax    
	mov rdx, rax
	xor r8, r8	

    .data_loop:
    test rcx, rcx
    jz .deal_with_vector
	push rbx
	push rcx
	push rdx
    call scanf
	pop rdx
	pop rcx
	pop rbx
	push rax
	add r8, rax
    dec rcx
    jmp .data_loop




    .deal_with_vector:
    test rbx, rbx
    jz .print
    pop rax
	mov [v+rbx], al
	dec rbx
	jmp .deal_with_vector

    .print:
	cmp rbx, rdx
	je .end
	mov al, byte [v+rbx+1]
	push rbx
	push rdx
	call print_int
	pop rdx
	pop rbx
	inc rbx
	jmp .print

	.end:
	mov rax, r8
	call print_int
    mov eax, 1          ; syscall: exit
    xor ebx, ebx        ; status de saída 0
    int 0x80