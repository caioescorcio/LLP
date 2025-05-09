    ; Carrega o registrador GDTR com o endereço da estrutura _gdtr.
    ; Essa estrutura informa ao processador onde está a GDT (tabela global de descritores).
    lgdt cs:[_gdtr]            ; GDTR recebe: limite de 6 bytes + endereço base da GDT

    ; Lê o conteúdo do registrador de controle CR0, que contém flags do modo operacional
    mov eax, cr0              ; !! Instrução privilegiada — apenas o kernel pode executar

    ; Ativa o modo protegido (Protected Mode) definindo o bit PE (Protection Enable), bit 0 de CR0
    or al, 1                  ; Define o bit 0 (PE) => ativa o modo protegido (real → protegido)

    ; Escreve o valor modificado de volta em CR0, ativando oficialmente o modo protegido
    mov cr0, eax              ; !! Instrução privilegiada

    ; Realiza um "far jump" para carregar um novo valor em CS (segmento de código)
    ; O seletor (0x1 << 3) = 0x08 aponta para o segundo descritor da GDT (índice 1), que é o segmento de código 32-bit
    jmp (0x1 << 3):start32    ; Pula para o rótulo 'start32' no segmento de código definido pela GDT

; ===================== Estrutura da GDT =====================

align 16                     ; Alinha o próximo dado na memória para 16 bytes (boa prática)

_gdtr:                       ; Estrutura com limite e base da GDT (usada com LGDT)
    dw 47                    ; Limite da GDT (tamanho - 1): aqui 48 bytes no total
    dq _gdt                  ; Endereço da GDT propriamente dita (base da tabela)

align 16                     ; Garante alinhamento da GDT para melhor desempenho

_gdt:
    ; Descritor nulo: obrigatório como primeira entrada da GDT
    ; Usado para capturar acessos inválidos a segmento 0
    dd 0x00, 0x00            ; 8 bytes preenchidos com zero

    ; ----------------- Descritor de Código (32-bit) -----------------
    ; Limite (Low):   0xFFFF
    ; Base (Low):     0x0000
    ; Base (Middle):  0x00
    ; Access Byte:    0x9A => Presente | Privilegiado (0) | Código | Executável | Leitura possível
    ; Flags + Limite: 0xCF => Granularidade 4K | 32-bit | limite alto = 0xF
    ; Base (High):    0x00
    db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00  ; Código 32-bit: executável

    ; ----------------- Descritor de Dados (32-bit) -----------------
    ; Igual ao código, mas o Access Byte é 0x92 (não-executável)
    ; Access Byte:    0x92 => Presente | Privilegiado (0) | Dados | Escrita possível
    db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00  ; Dados 32-bit: leitura/escrita

    ; Comentário visual explicando a estrutura de cada campo no descritor:
    ;  size  size  base  base  base  tipo  tipo|flags base
