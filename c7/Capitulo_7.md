# Capitulo 7 

Nesse capítulo existirão alguns desafios rodeando os exercícios propostos pelo autor. Entre eles um interpretador de Forth e a teoria sobre máquinas de estado e modelos de computação.

## 7.1 Máquinas de estado finitas

As máquinas de estado finitas (FSM - Finite State Machines) são uma abstração de um "autômato finito determinístico", que é uma forma de entender o fluxo de ação de um programa com base na lógica usada para interpretar cada input.

### 7.1.1 Definição

A descrição dessa máquina tange as seguintes propriedades:

1. Possui um conjunto de estados
2. Possui um alfabeto (conjuntos de símbolos para input)
3. Possui um estado inicial selecionado
4. Possui um ou mais estados finais selecionados
5. Possui regras de transição de estados. Cada regra consome um símbolo do alfabeto da seguinte forma: "Se o autômato estiver em um estado S e um símbolo C de entrada ocorrer, o próximo estado será Z"

Se o estado atual não possuir nenhuma regra para o símbolo de entrada atual o autômato possuirá comportamento "indefinido".

Esse conceito será abordado pensando nos seus casos "bons". Consideraremos todos os casos de comportamento indefinido como errôneos, indo para um estado de erro especial.

O autor cita uma situação em que é feito um autômato para a transição de estados A, B e C. Como esse conteúdo já foi abordado em matérias como Sistemas Digitais, do meu curso, não vou entrar em detalhes com figuras ou exemplos abstratos.

### 7.1.2 Exemplo: paridade de bits

Aqui o autor cita um exemplo de cálculo de paridade de bits, em que, a partir da leitura de uma string binária (zeros e uns), se determina a transição de estados entre um número impar de 1's para um número par de 1's a partir da leitura de um '1':

```asm

inicio - A: input 0 > A
            input 1 > B
            
       - B: input 0 > B
            input 1 > A

; Se o número for lido e o estado estiver em A, ele é par
; Caso contrário, ele é impar
```

### 7.1.3 Implementação em linguagem Assembly

O autor dá alguns insights de como criar um autômato desses em ASM. Para isso ele nos diz para:

1. Deixar o autômato projetado completo em papel: todo estado deve ter regras de transição para **qualquer** símbolo da entrada ou uma saída padrão de erro para caso não pensados ("regra-else")
2. Implementar uma rotina para obter o símbolo de entrada. Esse símbolo não é meramente um caractere, pode ser outros tipos de eventos globais
3. Para cada estado, devemos:
    - Criar um rótulo
    - Chamar a rotina de leitura de entrada
    - Casar o símbolo de entrada com os descritos nas regras de transição de estados e passar para os estados correspondentes
    - Tratar todos os demais símbolos com a regra-else

No exemplo do livro, temos a seguinte transição de estados:

```asm

inicio: A
fim: D
erro: E

A:  input "+" > B
    input "-" > B
    input 0..9 > C
    else  > E
B:  input 0..9 > C
    else > E
C:  input 0..9 > C
    input "\0" > D
    else > E

```

Seguindo esse exemplo, em `automaton_example_bits.asm`:

```asm
section .text

; getsymbol é uma rotina para let um símbolo (ex: stdin) em AL (de RAX)

_A: 
    call getsymbol
    cmp al, '+'
    je _B
    cmp al, '-'
    je _B

    cmp al, '0'
    jb _E
    cmp al, '9'
    ja _E
    jmp _C

_B: 
    call getsymbol
    cmp al, '0'
    jb _E
    cmp al, '9'
    ja _E
    jmp _C

_C:

    call getsymbol
    cmp al, '0'
    jb _E
    cmp al, '9'
    ja _E
    test al, al
    jz _D
    jmp _C

_D: 
    ; rotina de tratamento de sucesso

_E:
    ; rotina de tratamento de erros

```

Vemos nitidamente a transição de estados a partir dos 'jumps' no código.

### 7.1.4 Importância prática

Nem todos os programas podem ser transformados em máquina de estados finitas, pois esse tipo de abordagem dificulta tratamento de programas que usam recursão (que possui iterações inderteminadas), por exemplo.

C e Assembly são linguagens com máquinas de Turing completas, o que significa que são mais expressivas e podem ser usadas para resolver uma variedade maior de problemas.

Esse tipo de autômato é usado para sistemas embarcados, que possui funcionalidades pré-definidas, ou para protocolos, que possui sequências de dados para serem enviados.

Outro aspecto importante desses autômatos é a presença de estados inalcançáveis a partir de outro estado (que é importante para sistemas que requerem alta confiabilidade).

### 7.1.6 Expressões regulares

Vulgo (RegEx - Regular Expressions), constituem uma forma de codificar autômatos finitos. Elas declaram padrões textuais para substituí-los. A maioria dos editores de textos (VSCode, por exemplo) possuem elas implementadas. O autor nos instrui a tomar como exemplo o `egrep` - utiliátio do Linux. Ele segue as seguintes regras:

Uma expressão regular _R_, pode ser:

1. Uma letra
2. Uma sequênciade duas expressões regulares: _R Q_
3. Metassímbolos _^_ e _$_ que fazem correspondências no início e no final da linha
4. Um par de parênteses de agrupamento contendo uma expressão regular: _(R)_
5. Uma expressão OR: _R | Q_
6. _R*_ representa zero ou mais repetições de _R_
7. _R+_ representa uma ou mais repetições de _R_
8. _R?_ representa zero ou uma repetição de _R_
9. Um ponto corresponde a qualquer caractere: _._
10. Colchetes representam um intervalo de símbolos, por exemplo, _[0-9]_ é equivalente a _(0|1|2|3|4|5|6|7|8|9)_

Após seguir com alguns exemplos de RegEx, o autor nos traz as duas abordagens que alguns motores de RegEx usam no geral:

1. Utilizam sequências de símbolos descritas para tratar a expressão. Por exemplo ao tratar `ab` com a expressão `aa?a?b`:
    - Tentativa com `aaab` - falha
    - Tentativa com `aab` - falha
    - Tentativa com `ab` - sucesso

    Isso nos traz diferentes ramos de decisão em cima de uma expressão ou até que todas as decisões levem à falha.
    Essa abordagem é rápida e fácil de implementar, mas possui um cenário de pior caso em que a complexidade pode aumentar exponencialmente. Vamos tentar tratar `aaaaaaaa (...) aaaaa` ("a" repetido _n_ vezes) com `a?a?a?a?a? (...) a?a?aaaaaaaa (...) aaaaa` (repetição de "a?" _n_ vezes, seguido de "a" repetido _n_ vezes).

    Isso resultará em inúmeras comparações (2^n comparações até achar o resultado). Isso é um custo computacional muito alto. Esses casos são chamados de "casos patológicos".

2. Constroem uma FSM baseada em expressão regular. O seu nome é **NFA** (Non-deterministic Finite Automaton), que se opõe ao DFA (Deterministic Finite Automaton). Elas podem ter várias regras para o mesmo estado e para o mesmo símbolo de entrada. Isso resultará em mais de um estado simultâneo, resultando em um "macro-estado" conjunto entre todos os "estados atuais" do autômato. Para construir um autômato para RegEx usando uma NFA, podemos seguir as seguintes regras:

    - Um caractere corresponden a um autômato, que aceita uma string com um caractere desse tipo:
        ```asm
            inicio: A

            A - input: caractere > B
        ```
    
    - Podemos ampliar o alfabeto com símbolos adicionais, que colocaremos no final/início de cada linha, desse modo _^_ e _$_ serão como qualquer outro símbolo
    - Parênteses de agrupamento premitem aplicar regras aos grupos de símbolos. São usados somente para um parsing correto das expressões regulares (fornecem informações estruturais para a construção de um autômato correto)
    - OR corresponde à combinação de dois NFAs, mesclando seus estados (e gerando um outro "macro-estado") (vide figura 7.6 do livro)
    - Um asterisco corresponde a uma transição especial para o próprio estado e a um "else" para um estado intermediário à presença de outro caractere (vide figura 7.7 do livro)
    - A interrogação é implementada de maneira semelhante ao asterisco. _R+_ é implementado como _RR*_














