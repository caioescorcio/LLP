# Capitulo 1 

Antes do capítulo 1, o autor faz uma breve introdução sobre os conceitos a serem explorados nas 3 partes do livro. Eles variam desde a base teórica das máquinas de programar até multi-threading. Também há uma dedicatória do autor.


## Parte 1 - Linguagem Assembly e arquitetura de computadores

## 1 Básico sobre arquitetura de computadores

### 1.1 Arquitetura do núcleo

#### 1.1.1 Modelo de computação

Aqui há uma breve introdução sobre o que é que um programador faz e, como complemento, uma forma de diferenciar algoritmos para fazer as coisas. O exemplo dado é: ir ao supermercado. Nele se pode descrever ações do estilo "sair de casa" até mesmo "movimento do dedo mindinho da mão direita", fazendo um paralelo com os níveis das linguagens de programação.

Um modelo de computação é um conjunto de operações básicas e seus respectivos custos. Eles são máquinas abstratas que descrevem o andamento de um algoritmo com base no sistema de memória que ele utiliza.

#### 1.1.2 Arquitetura de von Neumann

Em 1930, von Neumann (pai do Merge Sort) descreveu um modelo de computação que separa a memória da CPU, possibilitando uma programação fácil e ao mesmo tempo robusta. Outros exemplos de máquinas abstratas citadas são a Lambda de Church e a máquina de Turing.

Na MVN (Máquina de von Neumann), a memória armazena bits (0s e 1s), que possui instruções e dados. Ela é perpassada sequencialmente, posição a posição, com base na instruções presentes. 

O Assembly, por si só, é uma linguagem que também descreve 0s e 1s da memória, mas por meio de mnemônicos (abreviações das funções).

Nota do autor: O estado da memória e os registradores descrevem inteiramente o estado do computador (CPU). Compreender uma instrução não corresponde a compreender seus efeitos sobre a CPU.

### 1.2 Evolução

#### 1.2.1 Desvantagens da arquitetura de von Neumann

Em uma análise simples: não é interativa, pois requer edição manual da memória para visualização do conteúdo. Além disso, não aborda multitarefas, pois ela é 100% sequencial (usa de "ação e reação" da CPU/MEM para executar as funções). Finalmente, todos com acesso à máquina podem executar qualquer tipo de instrução sem se preocupar com os resultados (falta de um OS, que serve justamente para gerenciar recursos e evitar o caos). Antigamente também, as memórias e as CPUs tinham desempenhos similares, evitando gargalos. Isso hoje deve garantir a criação de sistemas de melhor acomplamento CPU/MEM, tendo em vista a grande diferença de desempenho entre esses dois componentes.

#### Arquitetura Intel 64

No livro será abordada a arquitetura x86_64/AMD64 ou apenas Intel 64. Os processadores são capazes de operar em uma série de modos: real, protegido, virtual, etc. Sem ser especificado, descreveremos o modo da CPU como *long mode* (o mais recente).

#### Extensões da arquitetura

Intel 64 incorpora extensões à MVN, como:

- Resgistradores (celulas de memória básicas)
- Pilha de hardware (estrutura de dados que possui `pop` e `push`, para remover e adicionar elementos, muito usadas em funções)
- Interrupções (que servem para tratar exceções)
    - Sinal externo
    - Divisão por 0
    - Instrução inválida
    - Falta de privilégios
- Anéis de protueção (que determina as instruções disponíveis para o usuário que as executará)
- Memória virtual (que abstrai a memória física para melhor distribuição entre aplicações)

Os autores mencionam o livro Intel 64 and IA-32 Architectures Software Developer's Manual, para aprender mais sobre as funções do Assembly de forma atualizada e voltada aos 64 bits.

### 1.3 Resgistradores

Células de memória: poucas porém rápidas. E caras. Enquanto os 'regs' são baseados em transistores, a memória principal é baseada em condensadores. Fato é, mais registradores implica em mais complexidade ao sistema, seja por causa do endereçamento, seja por causa da otimização para busca.

Se tudo tiver que ser buscado e inserido nos regs antes do processamento e depois descarregado na memória, qual a vantagem do uso de registradores? Isso nos traz para a *localidade de referência*:

- Localidade temporal: "se algo foi recentemente acessado, a tendência é que esse algo seja acessado novamente logo em seguida."
- Localidade espacial: "se algo foi recentemente acessado, a tendênica é que os regs nas suas proximidades sejam acessados em seguida."

Os programas típicos tendem a poder armazenar as suas variáveis em registradores para atender as localidades e, só depois de usá-las, descarregamos os valores dos regs na memória. Mas mesmo com todos esses princípios de localidade, temos que nos atentar a possíveis perdas de desempenho:

- Como buscar dados na memória e trazê-los ao processador?
- O que fazer se todos os registradores estiverem ocupados?

É comum engenheiros reduzirem o desempenho no pior caso para melhorá-lo no caso médio.


#### 1.3.1 Registradores de propósito geral

São regs intercambiáveis que proporcionam, nos seus 64 bits, uma visão de lógica através dos seus "apelidos" (*alias*). 

Abaixo se encontra uma tabela sobre os 16 regs de propósito geral abordados no livro:

| Número | Nome    | Alias       | Descrição                                              |
|---------|---------|------------|--------------------------------------------------------|
| R0     | RAX     | EAX, AX, AL | Acumulador principal, usado em operações aritméticas (como o auxiliar para multiplicações com mais de 64 bits) e retornos de chamadas de função. |
| R3     | RBX     | EBX, BX, BL | Base register, historicamente usado como ponteiro para dados (endereçamento). |
| R1     | RCX     | ECX, CX, CL | Contador, usado em loops e operações de deslocamento. |
| R2     | RDX     | EDX, DX, DL | Utilizado para operações de multiplicação e divisão, e para armazenar parte de valores estendidos, similar ao caso do RAX. |
| R6     | RSI     | ESI, SI    | Índice-fonte, usado para operações com strings e acesso a memória. |
| R7     | RDI     | EDI, DI    | Índice-destino, usado para operações com strings e destino de memória. |
| R5     | RBP     | EBP, BP    | Base pointer, usado para armazenar o endereço do frame da pilha. |
| R4     | RSP     | ESP, SP    | Stack pointer, aponta para o topo da pilha (valor do topo da pilha). |
| R8      | R8      | R8D, R8W, R8B | Registrador adicional |
| R9      | R9      | R9D, R9W, R9B | Registrador adicional |
| R10     | R10     | R10D, R10W, R10B | Registrador adicional, também pode armazenar flags da CPU |
| R11     | R11     | R11D, R11W, R11B | Registrador adicional |
| R12     | R12     | R12D, R12W, R12B | Registrador adicional |
| R13     | R13     | R13D, R13W, R13B | Registrador adicional |
| R14     | R14     | R14D, R14W, R14B | Registrador adicional |
| R15     | R15     | R15D, R15W, R15B | Registrador adicional |

Apesar de quase intuitivos, esses nomes alternativos são uma espécies de legados dos processadores antigos, pois essa semântica é usada hoje como apenas uma referência. Em geral, não se usa RBP e RSP por causa dos seus significados para a pilha. Podemos usar como "valor" para os registradores os seus 32, 16 ou até mesmo os 8 bits menos significativos.

Quando os r0...r15 são usados, adiciona-se um sufixo na denominação para indicar como a localização da sua palavra utilizá-vel:

- r7b, é o valor dos 8 bits finais (byte) de r7
- r7b, é o valor dos 16 bits finais (2 bytes) de r7
- r7b, é o valor dos 32 bits finais (4 bytes) de r7

Veja o seu uso:

63---------------------31--------15------7------0

| --------------------- rdi ----------------------|

| --------------------- |------------edi----------|

| --------------------- | ------------|-----di----|

| --------------------- | ------------|----|-dil--|


O preenchimento dos bits não usados para armazenar os valores são preenchidos com sinais, mas mudam com base na arquitetura. Por exemplo: há casos que se edi for -1, os bits mais significativos são transformados em 1's (complemento de 2) ou em 0's.

#### 1.3.2 Outros registradores

Os demais regs também podem ter significados especiais, podendo até terem valores imutáveis ao usuário.

Exemplo: o reg `rip` armazena o endereço da próxima instrução (PC - vindo do program counter), ele é acessível por meio de instruções de `jmp`, por exemplo. Já o `rflags` armazena as flags da CPU, com trechos `eflags` e `flags` para suas subdivisões.

Questão 1: CF, AF, ZF, OF E SF: 

| Flag  | Nome              | Descrição |
|--------|------------------|-----------|
| **CF** | Carry Flag       | Indica **transbordo (carry-out) no bit mais significativo** de uma operação aritmética sem sinal. Se uma soma resulta em um valor maior que o permitido pelo registrador, ou uma subtração tenta ir abaixo de zero, este flag é ativado. |
| **AF** | Auxiliary Carry Flag | Usado internamente para operações BCD (Binary-Coded Decimal). Indica um carry entre os **nibbles** (4 bits) menos significativos. |
| **ZF** | Zero Flag        | Definido como **1 se o resultado de uma operação for zero**. Muito utilizado em instruções de comparação e controle de fluxo, como `JZ` e `JNZ`. |
| **OF** | Overflow Flag    | Indica **overflow em operações com sinal**. Se uma operação gera um resultado maior ou menor do que pode ser representado com o número de bits disponíveis, este flag é ativado. |
| **SF** | Sign Flag        | Reflete o **bit mais significativo** do resultado de uma operação, indicando se o número é negativo (1) ou positivo (0) em operações com sinal. |

A diferença de OF para SF é o seu significado aritmético. Enquanto a SF apenas indica o sinal da operação resultante, a OF pode ser um indicador de erro na interpretação do sinal dado um overflow.

Para casos de floating point (`fp`), , regs de 128 bits podem ser usados (são presentes geralmente na interpretação de vídeo), como `xmm0`...`xmm15`. Também há regs exclusivos de modelos de processadores.

### 1.3.3 Registradores de sistema

São regs projetados para serem usados pelo OS, não interferindo na execução de programas do usuário. Eles oferecem um framework para a CPU processar os dados essenciais para o OS, bem como o seu isolamento. Eles devem ser inacessíveis para as aplicações (modo privilegiado apenas).

Exemplos:

- cr0, cr4: armazenam flags de modos de processador e memória virtual
- cr2, cr3: suporte para memória virtual
- cr8 (alias tpr): ajuste fino de interrupções
- efer: reg de flag usado para controle do modo do processador e as extensões (modo longo e tratamento de syscalls por exemplo)
- idtr: armazena o endereço da tabela de descritores
- cs, ds, ss, es, gs, fs: regs de segmento, usados para implementar o modo privilegiado, mas considerados legado

### 1.4 Anéis de proteção

Mecanismos para limitar a capacidade de aplicações por razões de segurança e de robustez. Originados do Multics (precursos do Unix). O nível atual de privilégio é armazenado sempre (regs especiais).

No Intel 64, existem 4 níveis de privilégio, mas 2 são usados na prática: o anel 0 (mais privilegiado) e o anel 3 (menos privilegiado). Os anéis intermediários são para uso de drivers e outros serviços do OS. 

De modo geral, o anel de proteção atual é armazenado nos dois bits menos significativos do c (duplicados dos bits de ss). Eles só podem ser alterados por meio de tratamento de uma interrupção ou syscall.

### 1.5 Pilha de hardware

Em linhas rasas:

- `push` + argumento: conforme o tamanho do argumento (2, 4 ou 8 bytes são permitidos), o valor de `rsp` será decrementado de 2, 4 ou 8 bytes. Um argumento é armazenado na memória começando no endereço do `rsp` modificado.

- `pop` + argumento: o elemento no topo da pilha é copiado para o reg/memória e `rsp` é incrementado com o tramanho do seu argumento. 

A pilha é mais conveniente para implementar linguagens de alto-nível para salvar contextos.
 
1. Nunca há pilha vazia, o `pop` pode ser executado independentemente, mesmo que signifique retornar lixo de memória.
2. A pilha cresce para o zero.
3. Os operandos obedecem complemento de 2:
    - `push -1` > 0xffffffffffffffff na pilha
4. Existem arquiteturas que armazenam o "próximo endereço" ao invés do endereço atual da pilha.


OBS: para a leitura de códigos Assembly é assim:

`OPCODE` + `INSTRUCTION` + `64-BIT MODE` + `DESCRIPTION`:

push    r ou m     16      : push de um reg de 16 bits de propósito geral ou um número de 16 bits da memória para a pilha (r é reg de propósito geral e m é localização da memória)

### 1.6 Resumo

Nos próximos capítulos criaremos uma biblioteca básica para *nix a fim de facilitar a interação com o usuário.