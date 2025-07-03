docol: 
    sub rstack, 8       ; puxa a instrução do topo da pilha 
    mov [rstack], pc    ; salva PC no topo da pilha
    add w, 8            ; vai para a double-word (vide o struct da célula) do ponteiro da implementação da palavra
    mov pc, w           
    jmp next

exit:
    mov pc, [rstack]    ; retorna o rstack
    add rstack, 8       ; pula pra próxima instrução
    jmp next