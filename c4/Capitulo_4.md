# Capitulo 4 

Este capítulo aborda o modo de implementação da virtualização da memória do Intel 64.

## 4.1 Caching

O conceito de caching é diretamente relacionado à proximidade de memória ao processador quando comparada aos outros níveis de memória. Disco é maior que a RAM e, logo, é mais difícil de se manusear. A RAM é maior que a Cache e, logo, é mais lenta. A Cache é o nível de memória mais rápida, cara e próxima ao processador, por isso é importante.

Vale mencionar que o disco rígido também tem cache próprio e, em relação ao processador, existem diversos níveis de cache (L1, L2, e L3), que também obedecem certa hierarquia de velocidade/tamanho, se aproximando até aos próprios registradores. Além disso, as CPUs tem sempre, no mínimo um cache de instrução e um Translation Lookaside Buffer (buffer de tradução de endereço) para melhorar o desempenho da memória virtual.

A abstração de Cache é um nível de memória auxiliar mais rápida para uma memória inicial.

O uso da Cache é relacionada ao conceito de Princípio da Localidade (que diz que geralmente, um acesso à memória é seguido de acessos de memória em posições adjacentes). A Cache permite a memória virtual utilizar a memória física para porções de instruções.

## 4.2 Motivação

A execução multi-tarefa/paralelizada de instruções requer determinados desafios:

- Executar programas de tamanhos arbitrários (carregamento de apenas parte de um programa no futuro próximo)
- Ter vários programas na memória ao mesmo tempo (programas de interação com dispositivos, etc) e alternância entre programas
- Armazenar programas em qualquer lugar da memória física (permitindo a alocação de qualquer posição da memória, mesmo com endereçamento absoluto)
- Livrar programadores de tarefas de memória o máximo possível
- Ter eficiência para compartilhamento de dados e códigos compartilhados

## 4.3 Espaços de endereçamento

Um _espaço de endereçamento_ é um intervalo de endereços, que pode ser de dois tipos:

- O endereço físico: usado para acessar bytes do hardware. Ele deve obedecer o tamanho da memória física e os espaços já alocados (ou proibidos)
- o endereço lógico: uma forma de endereço virutal em que o programador vê a posição de memória como visto no código (ex: `mov rax, [0x10bfd]`, em que o endereço lógico é [0x10bfd] - que não é seu endereço físico - e está visível ao programador). Vale mencionar que esse endereço corresponde a um endereço físico virtualizado e, portanto necessita de uma MMU (Memory Management Unit) para a tradução de endereços lógicos (virtuais) para endereços físicos.

## 4.4 Recursos

Falando sobre memória virtual, o autor menciona que, com a sua utilização, é possível abstrair que todo programa na verdade é separado como único consumidor da memória. O espaço de endereçamento de um processo é dividido em "páginas" (que em geral tem 4 KB) e  podem ser copiadas para chamados "arquivos de swap", que ficam em áreas de armazenamento externo.

Entre os recursos das memórias virtuais, estão:

- Acessar dispositivos externos
- Acessar o sistema de arquivos
- Permitir o compartilhamento de páginas entre processos
- Proibir o acesso a certos endereços (geralmente causando um término anormal da atividade - ex: Seg. Fault)
- Possuir páginas que não correspondem ao sistema de arquivos (ex: página de pilha, heap, etc)

O autor fala sobre "regiões", que começam em endereços múltiplos do tamanho da página (ex: endereços de 4 KB) e todas as páginas possuem a mesma permissão.

Sobre o swap, é de se mencionar que existem estratégias para a realização de swap e também que existem arquivos de swap (que servem para "guardar temporariamente" o processo). Sobre essas estratégias de escolha de páginas que sofrerão swap, elas podem ser como:

- Trocar a menos recentemente usada
- Trocar a mais recentemente usada
- Trocar aleatoriamente
- FIFO

* A alocação dinâmica é o processo em que mais páginas que o usual são alocadas ao longo do processo (pois o programa não pode aloca-las) 

## 4.5 Exemplo: acessando um endereço proibido

Nos próximos exemplos, observaremos os seguintes tipos de segmentos de memória:

- Correspondentes ao arquivo executável
- Correspondente a bibliotecas
- Correspondente a pilha e a heap
- Somente regiões vazias de endereços proibidos

Usaremos o 'procfs' do Linux para verificar os processos, com um `cat /proc/PID/maps` para ver o mapa da memória

Com o arquivo `mappings_loop.asm`:

```asm
section .data

    correct: dq -1

section .text

global _start

    _start:
    jmp _start; loop infinito
```

No processo feito, temos a seguinte alocação:

```
caio@Caio:/mnt/c/Users/caioe/Documents/Projetos/LLP$ cat /proc/1055/maps
00400000-00401000 r--p 00000000 00:53 3377699720798044                   /LLP/c4/codigos/mappings_loop.exe
00401000-00402000 r-xp 00001000 00:53 3377699720798044                   /LLP/c4/codigos/mappings_loop.exe  - código (X de execute)
00402000-00403000 rw-p 00002000 00:53 3377699720798044                   /LLP/c4/codigos/mappings_loop.exe  - dados (W de write) - lembrar dos descritores
7ffdde5f6000-7ffdde617000 rw-p 00000000 00:00 0                          [stack] - fora do sistema de arquivos pois é anonimo
7ffdde64c000-7ffdde650000 r--p 00000000 00:00 0                          [vvar]
7ffdde650000-7ffdde652000 r-xp 00000000 00:00 0                          [vdso]
```

Na coluna da esquerda, temos a região de memória alocada de 4KB em 4KB (0x1000 bytes). Note que o espaço de endereçamento é enorme (0x00400000 é o inicio) mas apenas poucos espaços estão alocados (endereços proibidos)

A coluna "00:53" é o identificador do dispositivo (major:minor) onde o arquivo reside. 00:53 indica qual dispositivo de bloco (disco) contém o arquivo. Já e coluna de "3377699720798044" é um identificador único para o arquivo, por isso as demais linhas não os possuem (anonimas).

Para exemplificar Segmentation Fault, usaremos uma alocação em um local proibido (antes de 0x00400000 que o processo começa). Em `segfault_badaddr.asm`:

```asm
section .data
correct: dq -1

section .text
global _start
start:

mov rax, [0x00400000-1]

mov rax, 60
xor rdi, rdi
syscall
```

Resulta em um Segmentation Fault, pois acessa ederenços antes de 0x00400000.

## 4.6 Eficência

Uma vez que o ato de realizar um swap é algo muito custuoso para o sistema, usa-se o princípio da localidade para que seja evitada a situação em que algum a página seja mal-alocada. Caso isso ocorra o prejuízo operacional é muito lento, mas quase nunca ocorre graças à eficiência de operação.

Para tal eficiência existe om TLB (Translational Lookaside Buffer) que é um cache de endereços de páginas traduzidas, ele armazena os endereços físicos de algumas páginas que _provavelmente_ trabalharemos.

## 4.7 Implementação

Veremos como a tradução de páginas ocorre.

### 4.7.1 Estrutura de endereços virtuais

Cada endereço de 64 bits possui uma estrutura predeterminada que indica como é feita a tradução. Temos um total de 48 bits de endereço apenas, ele é extendido para um "endereço canônico" de 64 bits com sinal. É uma forma de validação do endereço, pois ocnsidera que os 17 bits mais à esquerda sejam iguais para que o endereço seja válido (os 16 bits adicionais e o 48o bit original).

A estrutura geral segue a seguinte lógica:

- [63:48]: Repetição do 48o bit 
- [47:39]: Índice na tabela de mapeamento de páginas de nível 4
- [38:30]: Índice na tabela de ponteiros para diretório de páginas
- [29:21]: Índice no diretório de páginas
- [20:12]: Índice na tabela de páginas
- [11:0]: Offset a partir do início da página

* Os 48 bits de endereços virtuais são transformados em 52 bits de endereço físico com ajuda de tabelas especiais.
* Ao usar um endereço não-canônico sem querer, você verá uma mensagem diferente (Bus error).

O espaço físico é preenchido com regiões de páginas virtuais que são chamados de "frames de página" (as quais não possuem lacunas entre si e por isso elas sempre começam com um endereço com os últimos 12 bits iguais a zero - _offset_ - pois não faz sentido a existência de um offset não nulo para o início de uma região).

Os demais bits do endereço na verdade são índices para as tabelas de tradução (4KB cada). Vale mencionar que cada registro de memória com 64 bits possui uma parte do endereço inicial da próxima tabela.

## 4.7.2 Tradução de endereços em detalhes

O CR3 é o registrador que aponta para o início da primeira tabela. Ela se chama PML4 (Page Map Level 4) e sua busca funciona da seguinte maneira:

- Os bits [51:12] são disponibilizados por _cr3_
- Os bits [11:3] correspondem aos endereços [47:39] do endereço virtual
- Os 3 últimos bits são nulos.

As entradas da PML4 são as PML4E. O próximo passo agora é buscar na Tabela de Ponteiros para Diretório de Páginas:

- Os bits [51:12] são disponibilizados pela PML4E
- Os bits [11:3] corresppndem aos bits [38:30] do endereço virtual
- Os 3 últimos bits são nulos.

Esse processo é feito por mais duas tabelas até que se acha o endereço do frame da página (ou os seus bits [51:12], que serão usado para endereçamento físico e, com os 12 bits restantes, serã obtido o enderço virtual).

* O processo pode parecer longo mas, graças à TLB, acessamos páginas virtuais já traduzidas e de maneira rápida.

A estrutura da Tabela de Páginas funciona da seguinte maneira:

- [63]: execution-disabled bit, que proíbe a execução da página
- [62:52]: Reservado .
- [47:12]: Frame de página
- [11:9]: AVL, available (para desenvolvedores)
- [8:7]: misc, miscelaneo
- [6]: D, dirty (se a página foi modificada depois de ter sido carregada)
- [5]: A, acessado
- [4]: PCD, Page Cache Disable, desativar o cache da página
- [3]: PWT, Page Write-Through, se pode-se ignorar o cache ao escrever na página
- [2]: U, Usuário (se pode ser acessador no ring3)
- [1]: W, Writable
- [0]: P, presente na memória física

Se P não estiver ativo, ocorreu um erro na tentativa de acessar a página e ocorrerá o código #PF (Page Fault), que o OS lida carregando a respectiva página. Isso pode ser usado para a criação de um algoritmo "lazy" de acesso à memória, visando carregar partes do arquivo ao longo da sua utilização.

O OS usa o bit W para proteger a página contra modificações, por exemplo, em caso de compartilhamento de páginas durante um processo.

A tecnologia DEP (Data Execution Prevention) é baseada no bit EXB (executable) e evita que dados sejam executados como instruções, por exemplo, em pilhas.

### 4.7.3 Tamanhos de página

A partir da hierarquia de tamanho de memória (diretório de página, ponteiro de diretório de página, etc), existem tamanhos diferentes para os endereços dos frames de cada região.

## 4.8 Mapeamento de memória

A `syscall` _mmap_ é usada para tipos de mapeamento de memória. Sua condição é:

- RAX = 9, identificador de syscall
- RDI = addr, endereço de início de página, se nulo, o OS pode escolher o endereço
- RSI = len, tamanho da região
- RDX = prot, flags de proteção
- R10 = flags utilitárias (compartilhadas ou privadas, anonimas etc)
- R8 = fd, file descriptor
- R9 = offset

## 4.9 Exemplo: mapeando um arquivo na memória

Usando a chamada de sistema _open_ é possível capturar o descritor de um arquivo:

- RAX = 2, identificador de syscall
- RDI = file name, ponteiro para uma string terminada com nulo, arquivo name.holding
- RSI = flags, de permissão
- RDX = mode, se `sys open` for chamada para criar um arquivo armazenará permissões no sistema de arquivos

O passo a passo para o exemplo deve ser:

- Usando `syscall` _open_ armazenaremos o descritor do arquivo em RAX
- Chama-se _mmap_ com argumentos relevantes (incluindo seu descritor vindo em RAX)
- Com a rotina `print_string` printaremos o descritor

### 4.9.1 Nomes mnemônicos para constantes

Semelhante ao `#define` de C, que armazenas nomes em tempo de compilação, usaremos o `%define` do NASM para o mesmo. Nisso, guardaremos algumas constantes vindas do manual do _mmap_ para o seu argumento `prot`:

```
PROT_EXEC: Pages may be executed
PROT_READ: Pages may be read
PROT_WRITE: Pages may be written
PROT_NONE: Pages may not be accessed
```

É possível realizar operações lógicas com esse tipo de constantes.

Para saber valores específicos para contantes, usa-se o cabeçalho de trechos da API de Linux em `/usr/include` ou na `lxr` ([Linux Cross Rerefence](https://lxr.linux.no/linux+/)). Pode-se usar o google para achar os valores também.

### 4.9.2 Exemplo completo

Para o exemplo final, usaremos uma biblioteca `io.asm` com as funções de print desejadas. Usaremos um arquivo `teste.txt`.

```
; Antes dos dados, usaremos os nossos defines

%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2


section .data
fname: db 'c4/codigos/teste.txt', 0    ; file name

section .text
global _start

; PRINT STRING ROUTINE

print_string:
    push rdi                ; salvamos RDI para que ele va para o RSI posteriormente
    call string_length      ; com o inicio da string em RDI e com o tamanho em RAX, podemos printar uma string
    pop rsi                 ; colocamos RDI, antes pushado, agora em RSI
    mov rdx, rax            ; RAX em RDX para o seu tamanho
    mov rax, 1              ; syscall de print_string (write)
    mov rdi, 1              ; 1 para dispositivo de stdout
    syscall
    ret

string_length:
    xor rax, rax            ; RAX = 0

    .loop:                  ; inicio do loop
    cmp byte [rdi+rax], 0        ; verifica se o RDI (inicio da string) com o offset (RAX) eh nulo
    jz .end                 ; se for, caractere \0 na string = fim
    inc rax                 ; se nao, aumenta-se o tamanho
    jmp .loop

    .end:
    ret                     ; retorna com o tamanho da string em RAX

_start:

; OPEN SYSCALL
mov rax, 2
mov rdi, fname
mov rsi, O_RDONLY           ; abre o arquivo somente para leitura
mov rdx, 0                  ; nao estamos criando um arquivo, logo eh um argumento sem sentido

syscall                     ; RAX agora possui o descritor do arquivo aberto (nome)

; MMAP SYSCALL

mov r8, rax                 ; R8 fica com o descritor antes em RAX
mov rax, 9                  ; MMAP
mov rdi, 0                  ; OS seleciona o local de armazenamento
mov rsi, 4096               ; 4KB de pagina
mov rdx, PROT_READ          ; a nova regiao criada sera de somente leitura
mov r10, MAP_PRIVATE        ; as paginas nao serao compartilhadas entre processos

mov r9, 0                   ; offset em teste.txt
syscall                     ; RAX agora tera o local mapeado

mov rdi, RAX                ; para printar o que foi mapeado
call print_string

mov rax, 60                 ; fim   
xor rdi, rdi
syscall

```

Acho que esse código é um dos mais impressionantes já feitos: ele procura um arquivo, pega seu descritor e aloca-o na memória (como se fosse uma grande string). Uma vez que o nosso descritor (ID do arquivo) armazenava uma string e nossa função `print_string` percorre-a até achar um "nulo", com o local da memória (ponteiro) recebido em RAX, quando a _syscall de open_ é chamada, é printado todo o conteúdo do arquivo que foi selecionado.
