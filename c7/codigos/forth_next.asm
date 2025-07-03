next:
    mov w, pc
    add pc, 8   ; para célula de 8 bytes
    mov w, [w]
    jmp [w]