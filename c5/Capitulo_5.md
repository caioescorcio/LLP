# Capitulo 5 

Nesse capítulo, o autor aborda o processo de compilação em algumas partes:

- O pré-processador: transforma o código do programa em outro código na mesma linguagem mas com algumas substituições de strings
- O compilador: codifica o código fonte em um arquivo com instruções de máquina (binários). Ele não está completo pois ainda precisa de outros arquivos complementares (bibliotecas, por exemplo) para a execução.
- O linker: agrega os arquivos compilados em um só executável (usa arquivos-objeto), com formatos típicos sendo ELF (Executable and Linkable Format) ou COFF (Common Object File Format)
- O loader: aceita um arquivo executável e preenche um espaço de endereçamento de um processo recém-criado para seus dados, pilha, metadatos, etc

## 5.1 Pré-processador

Nessa seção será discutida a função do macroprocessador NASM, pois ele realizar esse trabalho de 'tradução' para pré-processamento nos nossos programas. Abordaremos os tipos de substituições feitas no processo de linkagem.

### 5.1.1 Substituições simples

Um exemplo básico de substituição feito é o usado por `%define`. Em `define_cat_count.asm`:

```asm
%define cat_count 42

mov rax cat_count
```

Após o pré-processamento, o código seria algo encontrado ao executar o comando `nasm -E c5/codigos/define_cat_count.asm`, que gerará o código _na mesma linguagem original_ com as substituições dos defines:

```cmd
%line 3+1 c5/codigos/define_cat_count.asm
mov rax 42
```

Em que a diretiva `%line` significa: `%line <linha>+<ajuste> <arquivo>`.

Vale mencionar que as substituições chamam-se *macros*. O processo de "expansão de macros", os macros são substituídos por suas respectivas correspondências. Os resultados são chamados de "instâncias de macros". No exemplo, o número 42 na linha `mov rax, cat_count` é uma instância de macro. Nomes como `cat_count` são chamados de "símbolos de pré-processador".

*O NASM permite redefinir símbolos de pré-processador pré-existentes

Seria importante o pré-processador saber algumas coisas sobre a sintaxe da linguagem tratada, para envitar realizar substituições errôneas. Por exemplo, em `macro_asm_parts.asm`:

```asm
%define a mov rax,
%define b rbx

a b
```

A construção está correta, mesmo que `a` e `b` sozinhos não tenham valor lógico. Desde que o resultado final possua sentido na linguagem programada, o código poderá ser tratado pelo compilador.

Outro exemplo de sintaxe é caso de linguagems com "if" e "else". Uma sintaxe só com um "else" não faria sentido lógico, mas se o linker pôde traduzí-la para de um macro válido sintaticamente, o compilador pode receber o código mesmo assim. 

Os macros oferecem certa dose de automação e são muito úteis para linguagens de alto-nível que utilizem de otimizações (variáveis globais, por exemplo).


### 5.1.2 Substituições com argumentos

Aqui o autor exemplifica sobre macros com argumentos. Em `macro_simple_3arg.asm`:

```asm
%macro test 3
dq %1
dq %2
dq %3
%endmacro
```

No caso da chamda do `test`, deverá ser feita uma instanciação do tipo `test 666, 555, 444` para gerar um código do tipo:

```asm
dq 666
dq 555
dq 444
```

### 5.1.3 Substituição condicional simples

Também são aceitas condicionais nos macros do ASM. Em `macroif.asm`:

```asm
BITS 64
%define x 5
%if x == 10

mov rax, 100

%elif x == 15

mov rax, 115

%elif x == 200

mov rax, 0

%else

mov rax, rbx
%endif
```

O conteúdo gerado pelo código pode ser verificado usando o comando `nasm -E c5/codigos/macroif.asm`:

```asm
%line 1+1 c5/codigos/macroif.asm
[bits 64]
%line 16+1 c5/codigos/macroif.asm

mov rax, rbx
```

A condição dos "if" tem que obedecer artmética simples ou conjecturas lógicas.

### 5.1.4 Condicionais sobre a definição

É possível também decidir se uma parte do arquivo será montada ou não em tempo de compilação. Faz-se o uso de `%ifdef`. Ela é usada para verificar se determinado símbolo do pré-processador está definido. Veja `defining_in_cla.asm`:

```asm
%define flag 10
%ifdef flag 
hellostring: db 'Hello', 0
%endif
```

Nesse caso, é possível verificar que, uma vez que o macro 'flag' foi definido no pré-processamento (`%ifdef`), será definido também o trecho `hellostring`. Ao executar `nasm -E c5/codigos/defining_in_cla.asm`, mas sem o 'define', o output do código será nulo. 

Contudo, se o código usar uma condicional de definição e, por algum acaso, ela não esteja instanciada no código, é possível instanciar uma flag através do argumento `-d` do NASM: `nasm -E c5/codigos/defining_in_cla.asm -d flag`.

### 5.1.5 Condicionais sobre a identidade de textos

O macro `%ifidn` é usado para testar se strings de texto são iguais, montando o código subsequente baseado nessa comparação. Para fazermos esse tipo de macro, o autor usa como exemplo as condicionais para a criação de uma "função _pushr_". Ela funciona como um push mas, caso o registrador desejado seja `rflags`, ele usa o comando `pushf` ao invés de um `push`. Em `pushr.asm`:

```asm
%macro pushr 1
%ifidn %1, rflags
pushf
%else
push %1
%endif
%endmacro

pushr rax
pushr rflags
```

O output para essa função é:

```cmd
%line 5+1 c5/codigos/pushr.asm
push rax
%line 3+1 c5/codigos/pushr.asm
pushf
```

É possível usar esse tipo de macro sem estar 'Case Sensitive': `%ifidni`, para _ignore case_.

### 5.1.6 Condicionais sobre o tipo de argumento

O pré-processador pode identificar o tipo de argumento passado durante a etapa de tradução do macro. Isso pode ser feito através de `%ifid` - se é um identificador de macro, `%ifstr` - se é uma string, ou `ifnum` - se é um número. Observer `macro_arg_types.asm`:

```asm
%macro print 1
    %ifid %1
        mov rdi, %1
        call print_string

    %else
        %ifnum %1
            mov rdi, %1
            call print_uint
        %else
            %error "String literals are not supported yet"
        %endif
    %endif
%endmacro

myhello: db 'hello', 10, 0

_start: 
    print myhello
    print 42
    mov rax, 60
    xor rdx, rdx
    syscall
```

Que identifica os tipos de argumentos passados em `print` e transforma-os à sua correspondência:

```cmd
%line 16+1 c5/codigos/macro_arg_types.asm
myhello: db 'hello', 10, 0

_start:
%line 3+1 c5/codigos/macro_arg_types.asm
 mov rdi, myhello
 call print_string

%line 8+1 c5/codigos/macro_arg_types.asm
 mov rdi, 42
 call print_uint
%line 21+1 c5/codigos/macro_arg_types.asm
 mov rax, 60
 xor rdx, rdx
 syscall
```

Note que existe um tratamento de erro em uma das linhas com `%error`. Ele sobe um erro do formato digitado ("error: String literals are not supported yet") para casos em que nenhum dos requisitos seja satisfeito.

### 5.1.7 Ordem de avaliação: define, xdefine, assign

Esses três tipos de macros são tipos diferentes de interpretações para o uso de definições:

- `%define`: Para uma substituição postergada. Se um corpo do macro contiver outros macros, elas serão expandidas (traduzidas) após a sua substituição
- `%xdefine`: Para substituições em tempo de definiçao. A string resultante será usada em todas as definições assim que ela for substituída e depende delas serem instanciadas antes do seu chamado.
- `%assign`: Avalia expressões aritméticas e não leva em conta redefinições, assim como xdefine.

Pode paracer meio abstrato, mas vamos levar em conta o código `define.asm`:

```asm
%define i 1

%define d i * 3
%xdefine xd i * 3
%assing a i * 3

mov rax, d
mov rax, xd
mov rax, a

%define i 100   ; redefinição de i, mudará o %define

mov rax, d
mov rax, xd
mov rax, a
```

Com o seu processamento, temos:

```cmd
%line 5+1 c5/codigos/define.asm
%assing a 1 * 3

mov rax, 1 * 3
mov rax, 1 * 3
mov rax, a



mov rax, 100 * 3
mov rax, 1 * 3
mov rax, a
```

Note as diferenças entre as duas instâncias com `i`.

### 5.1.8 Repetição

Vamos usar agora o macro `%rep`. Ele pode ser usado para loops e para a execução de lógica a partir de variáveis em `%assign`. Em `rep.asm`:

```asm
%assign x 1 ; valores iniciais para 'a' e para 'x'
%assign a 0

%rep 10
    %assign a x+a
    %assign x x+1
%endrep

result: dq a
```

Produz um output `result: dq 55`, que é fruto de 10 somas sucessivas de `a` com os sucessores de `x`.

### 5.1.9 Exemplo: calculando números primos

Vamos analisar o código `prime.asm`. Ele gera um array de bytes e cada i-ésimo bytes será um se i for primo:

```asm
%assign limit 15    ; de 0 até 17, no array, com 0 e 1 como `0`
is_prime: db 0, 0, 1

%assign n 3 ; a partir de 3 (pois um e zero são primos)
%rep limit

    %assign current 1       ; inicia-se com a suposição que um número é primo
    %assign i 1
        %rep n/2
            %assign i i+1
            %if n % i = 0
                %assign current 0   ; caso exista um divisor entre 1 e ele, ele não é primo
                %exitrep
            %endif
        %endrep
        
    db current
    %assign n n+1                   ; incremento de n até limit

%endrep
```

Isso gera um array de `db`'s da seguinte forma:

```cmd
%line 2+1 c5/codigos/prime.asm
is_prime: db 0, 0, 1
 db 1
 db 0
 db 1
 db 0
 db 1
 db 0
 db 0
 db 0
 db 1
 db 0
 db 1
 db 0
 db 0
 db 0
 db 1

```

* Não vou fazer a questão 70, não achei que valesse a pena

### 5.1.10 Rótulos sem macros

É uma forma de, quando houverem muitas repetições de macros, cada instância de sua substituição, haja uma label aleatória e única para identificar aquele macro. Para isso é usada uma estrutura `%%labelname`, com um nome abitrário para essa label. Note que, para esse uso, ela virá como uma "flag" para cada instancia de macro feita. Veja em `macro_local_labels.asm`:

```asm
%macro mymacro 0
%%name1: AAAA
%%name2: 
%endmacro

mymacro
mymacro
mymacro
```

Gera um output do seguinte formato:

```cmd
%line 2+1 c5/codigos/macro_local_labels.asm
..@0.name1: AAAA
..@0.name2:
%line 2+1 c5/codigos/macro_local_labels.asm
..@1.name1: AAAA
..@1.name2:
%line 2+1 c5/codigos/macro_local_labels.asm
..@2.name1: AAAA
..@2.name2:
```

Note a progressão de cada identificador, bem como a rotulação feita para o macro.

### 5.1.11 Conclusão

"Podemos pensar em macros como a metalinguagem da programação executada antes da compilação"