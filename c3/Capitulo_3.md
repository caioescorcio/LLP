# Capitulo 3 

Legado

Nesse capítulo, serã abordados recursos legados relacionados aos modos de processador (anéis de proteção, Global Descriptors Table, etc). O autor menciona os modos que evoluíram ao longo do tempo com as novas implementações de processadores:

- Modo real (16 bits)
- Modo protegido (32 bits)
- Modo virtual (modo real dentro do modo protegido)
- Modo de gerenciamento (para modo sleep, gerenciamento de energia, etc)
- Modo longo (que usamos)

## 3.1 Modo Real

Sem memória virtual, memória física diretamente endereçada e com registradores de propósito geral de 16 bits (sem RAX ou EAX, mas AX, AL, AH). Eles podiam armazenar números de 0 até 65535 (64 Kb) em uma região chamada de _segmento_ (o autor adverte para que não seja confundida com os segmentos do Modo protegido ou com as seções de arquivo ELF - Executable and Linkable Format).

Os registradores são:

- ip (instruction pointer), flags;
- ax, bx, cx, dx, sp, bp, si, di;
- registradores de segmento: cs, ds, ss, es (além de posteriores gs e fs).

A dificuldade encontrada no uso desses registradores era o seu endereçamento, pois haviam apenas 64 Kb de memória. Logo foram criados os _registradores de segmento_ especiais:

- Cada endereço físico (posição na memória física) seria constituído por 20 bytes (5 dígitos hexadecimais). 
- Cada endereço lógico (endereço "visto pelo processador") é composto por dois componentes: um registrador de segmento (que indicao início do segmento) e o offset desse segmento. O hardware calcula o endereço total a partir da seguinte conta:

`endereço físico = base do segmento*16 + offset`

O formato visto é "segmento:offset", como: 4a40:0002 ou ds:0001, etc

Com o intúito de separar as unidades lógicas do circuito (pilha, execução, etc) são usados segmentos diferentes para determinar o tipo de dado usado. Os registradores de segmento são especializados nisso: _cs_ armazena o início do código, _ds_ armazena o início dos dados e _ss_ armazena o início da pilha. Vale ressaltar que os registradores de segmento não armazenam estritamento o endereço físico do registrador, mas as suas partes (4 bits mais significativos: XXXX YYYY 0000 0000, em que X e Y são os endereços "fisicos" dos registradores).

Cada instrução possui um tipo de segmento idealmente usado (por exemplo: `mov` manipula dados da memória, logo é provável que use o segmento de _ds_ em algum argumento implicitamente): 

`mov al, [0004]` seria equivalente a `mov al, ds:[0004]`

Mas também era possível endereçar manualmente o segmento: 

`mov al, cs:[0004]`

Durante o carregamento do programa, o Loader define os registradores de segmentos principais: _ip, cs, ss e sp_, onde `cs:ip` é a instrução atual e `ss:sp` é o topo da pilha.


A CPU sempre é iniciada em Modo Real para que, posteriormente, seja colocada em modo protegido e em modo longo.

Desvantagens do modo real:

- Dificulta multitasking (pois o mesmo espaço de memória é compartilhado para todos os programas e o posicionamento dos registradores para os programas é decidido durante a compilação)
- Os programas podem reescrever os códigos alheios (pois não a particionamento do endereçamento)
- Qualquer programa pode executar qualquer instrução, podendo prejudicar o Sistema Operacional.

## 3.2 Modo Protegido

O modo protegido (32 bits) oferece registradores maiores (eax, ebx, ...) e aneis de proteção, memória virtual e segmentação de memória. Dessa forma, houveram mudanças no modo de endereçamento físico dos registradores, usando agora uma tabela inicial ao invés de uma multiplicação direta:

`endereço linear ('físico') = base do segmento (obtido na tabela do sistema) + offset`

Cada registrador de segmento agora armazena um "seletor de segmento", com um índice na tabela de descritores de segmentos. Tais tabelas existem da seguinte maneira:

- Várias tabelas do tipo LDT (Local Descriptor Table)
- Uma GDT (Global Descriptor Table)

As LDTs foram criadas na intenção de alternância de tarefas, mas não são mais usadas devido à criação da virtualização de memória.

O GDTR (Global Descriptor Table Register) é o registrador que armazena o endereço e o tamanho da GDT. Ele é composto por index[15:3] + T[2](Table indicator, se é LDT ou GDT) + RPL[1:0] (Requested Privilege Level, onde 0 é Kernel e 3 é User).

O bit T é 0 pois não são mais usadas LDTs. O RPL armazena o privilegio em relação ao Descriptor Privilege Level (DPL), que é armazenado na tabela de descritores. Se o RPL não tiver privilégio suficiente para acessar determinado segmento, ocorrerá erro. 

*Níveis de privilégios = anéis de proteção*

O nível de privilégio é armazenado nos dois bits menso significativos de _cs_ ou de _ss_ (esses números devem ser iguais, pois não é coerente um ponteiro de instrução conter um privilégio diferente do ponteiro de pilha). Já em relação ao _ds_, é possível mudar os bits de privilégio para níveis de privilégio menores em relação ao atual (não é necessária a mesma validação). O exemplo dado no livro é: 

No ring0 (nivel de privilegio 0 = Kernel), com _ds_ = 0x02, é possível acessar dados apenas de níveis de privilégio maior que 2. Não é possível alterar _cs_ diretamente.

Sobre o descritor de segmento da GDT:

- [31:24]: Base[31:24]
- [23]: G, Granularidade (ex: G == 0, então o tamanho está em byes, se G == 1, o tamanho está como páginas de 4096 bytes cada)
- [22]: D, Tamanho default do operando (0 == 16 bits, 1 == 32 bits)
- [21]: L, é do modo longo (64 bits)?
- [20]: V, disponível para o softare do sistema?
- [19:16]: Tamanho[19:16]
- [15]: Presente na memória, no momento
- [14:13]: DPL, privilégio/ anel
- [12]: S, É dado/código(1) ou apenas armazena alguma informação do sistema (0)
- [11]: X, Dado (0) ou código (1)
- [10]: DC, Direção do crescimento (para endereços mais baixos ou mais altos), para segmento de dados (pode ser executado a partir de níveis mais elevados de privilégio?)
- [9]: RW, para segmentos de dados a escrita é permitida? Para segmentos de código a leitura é permitida?
- [8]: A, foi acessado?
- [7:0]: Base[23:16]

*Existe outro bloco de Base + tamanho que não coloquei

Para entrar no modo protegido, atualmente, é necessário criar a GDT e configurar o GDTR: ative o bit especial _cr0_ e faça um "far jump". Em que o segmento é explicitamente especificado (ex: `jmp 0x08:addr`). No arquivo 

```asm
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
```

É mencionado no livro que cada registrador de segmento possui um "registrador sombra", que serve como cache para o conteúdo da GDT e que, se é alterado o registrador de segmento, o registrador sombra é carregado com o descritor correspondente ao presente na GDT. Vale mencionar que a flag D é importante para determinados tipos de segmentos, pois pilhas, dados e códigos podem possuir tamanhos diferentes dependendo do seu uso (as explicações mais detalhadas permanecem no próprio livro). Vale mencionar, finalmente, que a segmentação é uma "fera selvagem", como aborda o autor do livro, mas que foi abandonada pelos engenheiros por alguns motivos:

- Não ter segmentação é mais fácil para os programadores
- Nenhuma linguagem de programação atualmente possui segmentação como modelo de memória (colocando tal tarefa ao compilador)
- Os segmentos fazem a fragmentação de memória um desastre
- A tabela de descritores pode armazenar 8192 descritores de segmento. Como utilizar essa pequena quantidade de maneira eficaz?

Tudo isso resultou no banimento da segmentação com a implementação do modo longo, onde, no entanto, ainda se usam anéis de proteção e, por isso, é necessário ao programador compreende-los.
