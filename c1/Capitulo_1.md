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