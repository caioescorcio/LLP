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

## 5.2 Tradução

A função do compilador é traduzir um código de uma linguagem para outra. No processo de tradução de linguagens de alto nível para máuina, existem várias etapas onde existem representações intermediárias entre o código e a linguagem-alvo (IR - Intermediate Representation). 

O compilador trabalha com unidades atômicas de código chamadas 'módulos', que correspondem a arquivos de código-fonte. Eles são compilados de forma independente e um arquivo-objeto é gerado a partir deles. No caso do Assembly, essa compilação/tradução é facilitada pois a tradução dos mnemônicos para linguagem de máquina é quase de 1 para 1.

Entretanto, a resolução de rótulos não é trivial, necessitando de processos não triviais.

## 5.3 Ligação

O processo de execução dos códigos em Assembly usado se baseia nas seguintes linhas de comando:

```sh
nasm -f elf64 -o "$BASENAME.o" "$1"
ld -o "$BASENAME.exe" "$BASENAME.o"
```

Veja a flag `-f elf64`, ela indica que usamos o formado de código-objeto em ELF64 bits (Executable and Linkable Format), para então ser usado pelo linker (comando `ld`) e transformá-lo em um executável.

Usaremos esse formato de arquivo para mostrar o que o Linker faz.

### 5.3.1 ELF (Executable and Linkable Format)

É o formato de arquivos-objeto mais comum em sistemas *nix. Ele permite três tipos de arquivos:

1. Arquivos-objeto relocáveis: '.o' gerados pelo compilador. Ser relocável indica que as posições de memória usadas durante o programa podem ser atribuídos a posições relativas e, logo, serem usadas em outros lugares da memória. A ordem em que esses arquivos são colocados na memória ainda não é definitiva.

2. Arquivos-objeto executáveis: '.exe' que podem ser carregados diretamente na memória.

3. Arquivos-objeto compartilháveis: que podem ser carregados quando requisitados pelo programa principal, comum para '.dll' do Windows ou '.so' do Linux.

O propósito do Linker é criar um arquivo-objeto executável dado um conjunto de arquivos relocáveis. Ele usa as seguintes tarefas para isso:

- Relocação
- Resolução de símbolos (sempre que um símbolo - função, variável - deixa de ser referenciado, o Linker deve modificar o arquivo-objeto para na nova posição correta de associação).

#### 5.3.1.1 Estrutura

Usando o comando `readelf -h c4/codigos/hello.o`, veremos a estrutura do cabeçalho ELF do arquivo-objeto de `hello.asm` do Capítulo 4:

```asm
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          0 (bytes into file)
  Start of section headers:          64 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         7
  Section header string table index: 3
```

Os arquivos ELF podem ser analisados de duas formas: do ponto de vista da ligação (`readelf -S c4/codigos/hello.o`) e do ponto de vista da execução (`readelf -l c4/codigos/hello.exe`)

- Ligação: Exibe uma tabela de seções com dados brutos a serem carregados na memória e metadados formatados de outras seções usados pelo loader (ex: `.bss`), pelo linker (ex: tabelas de relocação) e pelo depurador (ex: .line).

- Execução: Exibe informações necessárias ao sistema para executa o programa e o segmento de ELF que exibe as permissões (leitura, execução e escrita) garantidas pela memória virtual. Cada segmento (da mesma região de memória) mostra uma região da memória e o seu offset de uma região de memória. 

#### 5.3.1.2 Seções de arquivos ELF

O termo 'section' do NASM já foi visto nos contextos de '.data' e '.text'. Aqui vão todos os tipos de seções dos arquivos ELF:

- `.text`: armazena instruções
- `.data`: armazena variáveis globais inicializadas
- `.rodata`: armazena dados 'read-only' 
- `.bss`: armazena variáveis globais que podem ser lidas e escritas e iniciadas com zero. Não é necessário descarregar seu conteúdo em um arquivo-objeto pois essas variáveis já são nulas. Nesse contexto, apenas o tamanho total da seção é armazenado
- `.rel.text`: armazena uma tabela de relocação para a seção `.text`, usada para armazenar locais em que um linker deve modificar a seção de texto depois de escolhido um endereço de carga para o arquivo-objeto
- `.rel.data`: armazena uma tabela de relocação para a seção `.data`
- `.debug`: armazena uma tabela de símbolos para depurar um programa. Se o programa for escrito em C ou C++, armazenará não só as variáveis globais, mas as locais também
- `.line`: define a correspondência entre partes do código com os números das linhas do código-fonte (de alto para baixo nível). Ela permite que o código seja depurado linha a linha
- `.strtab`: armazena strings de caracteres ("array de strings" para o código)
- `.symtab`: armazena uma tabela de símbolos (como rótulos) e outras informações utilitárias

### 5.3.2 Arquivos-objeto relocáveis

Criaremos, com vários rótulos e seções, o `symbols.asm`:

```asm
section .data
datavar1: dq 1488
datavar2: dq 42

section .bss
bssvar1: resq 4*1024*1024
bssvar2: resq 1

section .text
extern somewhere

global _start
    mov rax, datavar1
    mov rax, bssvar1
    mov rax, bssvar2
    mov rdx, datavar2
    
_start:

jmp _start
ret
textlabel: dq 0
```

Note que são usados diretivas `extern` e `global` para marcar símbolos. Essas diretivas controlam a criação da tabela de símbolos. `extern` define símbolos que não estão definidos em outros módulos mas que são usados no módulo atual

* Símbolos globais são diferentes de rótulos globais 

Existem diversos comandos no Linux que permitem a análise de arquivos-objeto. 

Para consultar a tabela de símbolos, use `nm`.

Para exibir informações gerais, user `objdump`.

Para uma versão mais informações sobre um arquivo-objeto (sabendo ser ELF), use `readelf`.

Usando `nasm -f elf64 c5/codigos/symbols.asm && objdump -tf -m intel c5/codigos/symbols.o`:

```cmd  
c5/codigos/symbols.o:     file format elf64-x86-64
architecture: i386:x86-64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000

SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 c5/codigos/symbols.asm
0000000000000000 l    d  .data  0000000000000000 .data
0000000000000000 l    d  .bss   0000000000000000 .bss
0000000000000000 l    d  .text  0000000000000000 .text
0000000000000000 l       .data  0000000000000000 datavar1
0000000000000008 l       .data  0000000000000000 datavar2
0000000000000000 l       .bss   0000000000000000 bssvar1
0000000002000000 l       .bss   0000000000000000 bssvar2
000000000000002b l       .text  0000000000000000 textlabel
0000000000000028 g       .text  0000000000000000 _start
```

O significado de cada coluna é:

1. Endereço virtual do símbolo especificado em relação ao início da seção
2. Uma string de sete letras e espaços onde cada letra caracteriza um símbolo de algum modo. Ao nosso interesse:
    - l, g, -: local, global ou nenhum
    - I, -: um link para outro símbolo ou símbolo comum
    - d, D, -: símbolo de depuração, símbolo dinâmico ou símbolo comum
    - F, f, O, -: nome de função, nome de arquivo nome de objeto ou símbolo comum

    Os que estão presentes no arquivo são: f (nome do arquivo), d (necessários somente para depuração) e l (local para esse módulo).

3. Nome da seção que corresponde ao módulo
4. Mostra um número de alinhamento (ou sua ausência)
5. Nome do símbolo

* Símbolos são _case sensitive_

Vamos agora fazer o Disassemble para visualizar o objeto como a máquina o vê. Usando o `objdump` com a flag `-D` (de disassemble) e `-M intel-mnemonic` para indicar que queremos a sintaxe da Intel (`objdump -D -M intel-mnemonic c5/codigos/symbols.o`):

```cmd
c5/codigos/symbols.o:     file format elf64-x86-64


Disassembly of section .data:

0000000000000000 <datavar1>:
   0:   d0 05 00 00 00 00       rolb   $1,0x0(%rip)        # 6 <datavar1+0x6>
        ...

0000000000000008 <datavar2>:
   8:   2a 00                   sub    (%rax),%al
   a:   00 00                   add    %al,(%rax)
   c:   00 00                   add    %al,(%rax)
        ...

Disassembly of section .text:

0000000000000000 <_start-0x28>:
   0:   48 b8 00 00 00 00 00    movabs $0x0,%rax
   7:   00 00 00
   a:   48 b8 00 00 00 00 00    movabs $0x0,%rax
  11:   00 00 00
  14:   48 b8 00 00 00 00 00    movabs $0x0,%rax
  1b:   00 00 00
  1e:   48 ba 00 00 00 00 00    movabs $0x0,%rdx
  25:   00 00 00

0000000000000028 <_start>:
  28:   eb fe                   jmp    28 <_start>
  2a:   c3                      ret

000000000000002b <textlabel>:
        ...
```

O operando `mov` da seção `.text` com offsets, que deveriam representar as datavar e as bssvar estão nulos. Significa que o linker ainda vai preencher, ao criar o executável, com as posições de memória necessárias para referenciar essas variáveis. Esses endereços são vistos nas tabelas de relocação. Usando `readelf --relocs c5/codigos/symbols.o`: 

```cmd

Relocation section '.rela.text' at offset 0x430 contains 4 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000000002  000200000001 R_X86_64_64       0000000000000000 .data + 0
00000000000c  000300000001 R_X86_64_64       0000000000000000 .bss + 0
000000000016  000300000001 R_X86_64_64       0000000000000000 .bss + 2000000
000000000020  000200000001 R_X86_64_64       0000000000000000 .data + 8
```

Vemos uma associação entre os offsets de datavars, bssvars e suas posições de memória. 

Podemos fazer isso também usando `nm c5/codigos/symbols.o`:

```cmd
0000000000000028 T _start
0000000000000000 b bssvar1
0000000002000000 b bssvar2
0000000000000000 d datavar1
0000000000000008 d datavar2
000000000000002b t textlabel
```

### 5.3.3 Arquivos-objeto executáveis

Vamos analisar os arquivos executáveis agora. No arquivo `executable_object.asm`, com variáveis globais `somewhere` e `private`, além da função global `func`:

```asm
global somewhere
global func

section .data

somewhere: dq 999
private: dq 666

section .text

func:
    mov rax, somewhere
    ret
```

Executaremos comandos de compilação conjunta entre esse arquivo e `symbols.asm`:

```sh
nasm -f elf64 c5/codigos/symbols.asm
nasm -f elf64 c5/codigos/executable_object.asm
ld c5/codigos/symbols.o c5/codigos/executable_object.o -o c5/codigos/main.exe
objdump -tf c5/codigos/main.exe
```

Temos o seguinte output:

```cmd
c5/codigos/main.exe:     file format elf64-x86-64
architecture: i386:x86-64, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0000000000401028

SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 c5/codigos/symbols.asm
0000000000402000 l       .data  0000000000000000 datavar1
0000000000402008 l       .data  0000000000000000 datavar2
0000000000402020 l       .bss   0000000000000000 bssvar1
0000000002402020 l       .bss   0000000000000000 bssvar2
000000000040102b l       .text  0000000000000000 textlabel
0000000000000000 l    df *ABS*  0000000000000000 c5/codigos/executable_object.asm
0000000000402018 l       .data  0000000000000000 private
0000000000402010 g       .data  0000000000000000 somewhere
0000000000401028 g       .text  0000000000000000 _start
0000000000402020 g       .bss   0000000000000000 __bss_start
0000000000401040 g       .text  0000000000000000 func
0000000000402020 g       .data  0000000000000000 _edata
0000000002402028 g       .bss   0000000000000000 _end
```

Note que as flags são diferentes agora: temos a flag `EXEC_P`, pois é executável e não há mais a flag `HAS_RELOC` para tabela de relocação pois as tabelas já foram traduzidas.

### 5.3.4 Bibliotecas dinâmicas

Elas são arquivos-objeto ligados ao programa durante a execução. Enquanto bibliotecas estáticas são arquivos executáveis incompletos, as bibliotecas dinâmicas são um pouco diferentes.

- Elas são carregadas quando são necessárias
- Elas contém metainformações sobre o código disponibilizadas aos outros programas (loader)
- Podem ser atualizadas independentemente
- Podem ser carregadas em qualquer endereço
- Como são sujeitas a bugs, podem ser uma "bomba relógio"

Para que elas possam ser carregadas em qualquer endereço, existem algumas maneiras de construí-las:

- Pode-se realizar a relocação em tempo de execução (que facilita a duplicidade na memória física, que tem um ponto negativo para as "seções .text" dos programas - redundância). 
- Pode-se realizar algo chamado _PIC_ (Position Independent Code), que nos livraria completamente de endereços absolutos, usando posicionamento relativo do RIP (ex: `mov rax, [rip + 13]`), que facilita o compartilhamento das seções .text dos programas.

* Ao usar variáveis globais não-constantes é mais difícil que o código possa ser aproveitado por Threads e, como consequência, difícil de ser aproveitado como blibloteca dinâmica.

Vamos fazer uma biblioteca dinâmica. Em `libso.asm`:

```asm
Extern _GLOBAL_OFFSET_TABLE_

global func:function

section .rodata
message: db 'Shared object wrote this", 10, 0

section .text
func: 
    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, 14
    syscall
ret
```

Note que o `.rodata` é usada pois é apenas read-only (para facilitar o uso dinâmico). Agora na nossa main `libso_main.asm`:

```asm
global _start

extern func

section .text

_start:

    mov rdi, 10
    call func       ; chamado da nossa libso
    mov rdi, rax
    mov rax, 60
    syscall
```

Usaremos os seguintes comandos para acoplar nossos códigos um no outro:

```sh
nasm -f elf64 -o c5/codigos/main.o c5/codigos/libso_main.asm
nasm -f elf64 -o c5/codigos/libso.o c5/codigos/libso.asm
ld -o c5/codigos/main.exe c5/codigos/main.o -d c5/codigos/libso.o
ld -shared -o c5/codigos/libso.so c5/codigos/libso.o --dynamic-linker=/lib64/ld-linux-x86-64.so.2
readelf -S c5/codigos/libso.so
```

Temos o seguinte output:

```cmd
There are 13 section headers, starting at offset 0x3120:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .hash             HASH             0000000000000190  00000190
       0000000000000014  0000000000000004   A       3     0     8
  [ 2] .gnu.hash         GNU_HASH         00000000000001a8  000001a8
       0000000000000024  0000000000000000   A       3     0     8
  [ 3] .dynsym           DYNSYM           00000000000001d0  000001d0
       0000000000000030  0000000000000018   A       4     1     8
  [ 4] .dynstr           STRTAB           0000000000000200  00000200
       0000000000000006  0000000000000000   A       0     0     1
  [ 5] .rela.dyn         RELA             0000000000000208  00000208
       0000000000000018  0000000000000018   A       3     0     8
  [ 6] .text             PROGBITS         0000000000001000  00001000
       000000000000001c  0000000000000000  AX       0     0     16
  [ 7] .rodata           PROGBITS         0000000000002000  00002000
       000000000000001a  0000000000000000   A       0     0     4
  [ 8] .eh_frame         PROGBITS         0000000000002020  00002020
       0000000000000000  0000000000000000   A       0     0     8
  [ 9] .dynamic          DYNAMIC          0000000000003ef0  00002ef0
       0000000000000110  0000000000000010  WA       4     0     8
  [10] .symtab           SYMTAB           0000000000000000  00003000
       0000000000000090  0000000000000018          11     5     8
  [11] .strtab           STRTAB           0000000000000000  00003090
       000000000000002c  0000000000000000           0     0     1
  [12] .shstrtab         STRTAB           0000000000000000  000030bc
       0000000000000060  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), l (large), p (processor specific)
```

Note a presença de seções `.hash` - que é uma tabela hash para reduzir o tempo de pesquisa de símbolos para `.dynsym` -, `.dynsym` - que armazena os símbolos visíveis fora da biblioteca - e `.dynstr` - que armazena strings requisitadas por seus índices em `.dynsym`.

Executando `readelf -S c5/codigos/main.exe`:

```cmd
There are 6 section headers, starting at offset 0x2178:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000401000  00001000
       000000000000003c  0000000000000000  AX       0     0     16
  [ 2] .rodata           PROGBITS         0000000000402000  00002000
       000000000000001a  0000000000000000   A       0     0     4
  [ 3] .symtab           SYMTAB           0000000000000000  00002020
       00000000000000d8  0000000000000018           4     4     8
  [ 4] .strtab           STRTAB           0000000000000000  000020f8
       0000000000000055  0000000000000000           0     0     1
  [ 5] .shstrtab         STRTAB           0000000000000000  0000214d
       0000000000000029  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), l (large), p (processor specific)
```

### 5.3.5 Loader

O loader é a parte do SO que prepara um arquivo executável para a sua execução. Ele mapeia as seções relevantes do código na memória, inicia os vetores de `.bss` e, às vezes, mapeia outros arquivos da memória do disco.

Vamos analisar o mapeamento dos arquivos do programa `symbols.asm` usando os seguintes comandos:

```sh
nasm -f elf64 c5/codigos/symbols.asm
nasm -f elf64 c5/codigos/executable_object.asm
ld c5/codigos/symbols.o c5/codigos/executable_object.o -o c5/codigos/main.exe
readelf -l c5/codigos/main.exe
```

Temos o seguinte output:

```cmd
Elf file type is EXEC (Executable file)
Entry point 0x401028
There are 3 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x00000000000000e8 0x00000000000000e8  R      0x1000
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x000000000000004b 0x000000000000004b  R E    0x1000
  LOAD           0x0000000000002000 0x0000000000402000 0x0000000000402000
                 0x0000000000000020 0x0000000002000028  RW     0x1000

 Section to Segment mapping:
  Segment Sections...
   00
   01     .text
   02     .data .bss
```

Na tabela temos 3 elementos presentes. O segmento 00 não tem nenhuma seção mapeada, provavelmente contém alguma tabela ou outros metadados. Já a seção `.text` (carregada em 0x401000 e alinhada em 0x1000) e a seção `.data` (carregada em 0x402000 e alinhada em 0x1000) estão visíveis como segmentos 01 e 02.

O alinhamento significa que o endereço verdadeiro está mais próximo do início, divisível por 0x1000.

O autor mostra o mapeamento da memória usando PID também. Não achei relevante de se abordar aqui.

## 5.4 Exercício: dicionário

Ele está no diretório `c5/codigos/forth_int`

Sobre o exercício, faremos o primeiro passo para a implementação de um interpretador funcional de Forth.

Converteremos chaves para valores, em que cada entrada possui um endereço para próxima entrada, uma chave e um valor. No nosso caso, as chaves e os valores são ambas strings terminadas em nulo.

O exemplo a seguir (`linked_list_ex.asm`) apresenta um exemplo de lista ligada que armazena os valores 100, 200 e 300:

```asm
section .data

x1:
dq x2
dq 100

x2:
dq x3
dq 200

x3:
dq 0
dq 300
```

Vamos começar criando um arquivo ASM contendo as funções criadas para o `io.asm`. Esse arquivo vem lá do capítulo 2 e, como quando fui fazer o exercício, fiz as funções em arquivos separados, usarei o que está disponível no GitHub do autor. Esse arquivo se chamará `lib.asm`, que possuirá os rótulos das funções como variáveis globais.

Em `lib.asm`:

```asm
section .text
global string_length
global print_char
global print_newline
global print_string
global print_error
global print_uint
global print_int
global string_equals
global parse_uint
global parse_int
global read_word
global string_copy
global exit


string_length:
    xor rax, rax
.loop:
    cmp byte [rdi+rax], 0
    je .end 
    inc rax
    jmp .loop 
.end:
    ret

print_char:
    push rdi
    mov rdi, rsp
    call print_string 
    pop rdi
    ret

print_newline:
    mov rdi, 10
    jmp print_char

print_error:
    push rdi
    call string_length
    pop rsi
    mov rdx, rax 
    mov rax, 1
    mov rdi, 2 
    syscall
    ret

print_string:
    push rdi
    call string_length
    pop rsi
    mov rdx, rax 
    mov rax, 1
    mov rdi, 1 
    syscall
    ret

print_uint:
    mov rax, rdi
    mov rdi, rsp
    push 0
    sub rsp, 16
    
    dec rdi
    mov r8, 10

.loop:
    xor rdx, rdx
    div r8
    or  dl, 0x30
    dec rdi 
    mov [rdi], dl
    test rax, rax
    jnz .loop 
   
    call print_string
    
    add rsp, 24
    ret

print_int:
    test rdi, rdi
    jns print_uint
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint

; returns rax: number, rdx : length
parse_int:
    mov al, byte [rdi]
    cmp al, '-'
    je .signed
    jmp parse_uint
.signed:
    inc rdi
    call parse_uint
    neg rax
    test rdx, rdx
    jz .error

    inc rdx
    ret

    .error:
    xor rax, rax
    ret 

; returns rax: number, rdx : length
parse_uint:
    mov r8, 10
    xor rax, rax
    xor rcx, rcx
.loop:
    movzx r9, byte [rdi + rcx] 
    cmp r9b, '0'
    jb .end
    cmp r9b, '9'
    ja .end
    xor rdx, rdx 
    mul r8
    and r9b, 0x0f
    add rax, r9
    inc rcx 
    jmp .loop 
    .end:
    mov rdx, rcx
    ret

string_equals:
    mov al, byte [rdi]
    cmp al, byte [rsi]
    jne .no
    inc rdi
    inc rsi
    test al, al
    jnz string_equals
    mov rax, 1
    ret
    .no:
    xor rax, rax
    ret 


read_char:
    push 0
    xor rax, rax
    xor rdi, rdi
    mov rsi, rsp 
    mov rdx, 1
    syscall
    pop rax
    ret 

read_word:
    push r14
    xor r14, r14 

    .A:
    push rdi
    call read_char
    pop rdi

    cmp al, ' '
    je .A
    cmp al, 10
    je .A
    cmp al, 13
    je .A 
    cmp al, 9 
    je .A

    .B:
    mov byte [rdi + r14], al
    inc r14

    push rdi
    call read_char
    pop rdi
    cmp al, ' '
    je .C
    cmp al, 10
    je .C
    cmp al, 13
    je .C 
    cmp al, 9
    je .C
    test al, al
    jz .C
    cmp r14, 254
    je .C 

    jmp .B

    .C:
    mov byte [rdi + r14], 0
    mov rax, rdi 
    
    pop r14
    ret
   
string_copy:
    mov dl, byte[rdi]
    mov byte[rsi], dl
    inc rdi
    inc rsi
    test dl, dl
    jnz string_copy
    ret


exit:
    mov rax, 60
    syscall
```

Em seguida, será criado um arquivo `colo.inc`, que armazenará o nosso macro "colon" que criará palavras no dicionário (lista ligada). Ele deve receber dois argumentos:

- Uma string que é a chave do dicionário
- O nome do rótulo no Assembly

Cada entrada deve começar com um ponteiro para a próxima entrada e armazenar a chave como uma string terminada em nulo. Um exemplo do
arquivo `linked_list_ex_macro.asm`:

```asm
section .data

colon 'third word', third_word      ; "colon" deve ser invocado com a chave 'third_word' para que toda vez um código vier abaixo 
db "third word explanation", 0      ; ele seja executado da maneira descrita


colon 'second word', second_word
db "second word explanation", 0


colon 'first word', first_word
db "first word explanation", 0
```

O código acima deveria gerar uma saída do tipo:

```asm
section .data

label_3: 
dq 0
db "third word", 0

code_for_third_word:
db "third word explanation", 0  

label_3: 
dq label_1
db "second word", 0

code_for_second_word:
db "second word explanation", 0

label_1: 
dq label_2
db "first word", 0

code_for_first_word:
db "first word explanation", 0
```


Com isso em mente, em `colon.inc`:

```asm
%define previous_position 0                     ; inicia o dicionario na posicao zero

%macro colon 2                                  ; macro com dois argumentos
%%previous_position: dq previous_position       ; cria um label único (%%) para uma quad-word do que estava na posição anterior
dq %1, 0                                        ; armazena o valor da string finalizada em zero

code_for_%+ %2:                                 ; inicia o código para a próxima função (note que é usado um "%+ " para aglutinar strings)

%define previous_position %%previous_position   ; 'incremento' do valor da posição passada para uma nova posição usando a sua label

%endmacro
```

Testamos usando o arquivo `colon.test`:

```asm
%define previous_position 0                    
%macro colon 2                                  
%%previous_position: dq previous_position       
dq %1, 0                                        
code_for_%+ %2:                                 
%define previous_position %%previous_position   
%endmacro

section .text

colon "teste um", one
mov rax, 0

colon "teste dois", two
mov rax, 10
mov rbx, 10

colon "teste tres", three
mov rax, 100
mov rbx, 100
mov rcx, 100

colon "teste quatro", four
mov rax, 1000
mov rbx, 1000
mov rcx, 1000
mov rdx, 1000
```

Ele é transformado (usando `nasm -E c5/codigos/forth_int/colon.test`):

```cmd
[section .text]

..@1.previous_position: dq 0
dq "teste um", 0
code_for_one:
mov rax, 0

..@2.previous_position: dq ..@1.previous_position
dq "teste dois", 0
code_for_two:
mov rax, 10
mov rbx, 10

..@3.previous_position: dq ..@2.previous_position
dq "teste tres", 0
code_for_three:
mov rax, 100
mov rbx, 100
mov rcx, 100

..@4.previous_position: dq ..@3.previous_position
dq "teste quatro", 0
code_for_four:
mov rax, 1000
mov rbx, 1000
mov rcx, 1000
mov rdx, 1000
```

Note que é usada uma abordagem em que sempre se aponta para o código anterior. O autor não tinha deixado claro que era possível criar uma string aglutinada dessa maneira, nem que o dicionário conteria o código abaixo do cólon.

Vamos agora criar uma função `find_word`, em `dict.asm`. Ela aceitará dois argumentos: o ponteiro para uma string e um ponteiro para a última palavra do definida no dicionário. A `find_word` comparará todas as entradas do dicionário, retornando o endereço do registro caso ela a encontre ou 0 caso contrário:

```asm
global find_word
extern string_equals

section .rodata
msg_noword: db "No such word",0

section .text
find_word:                          ; RDI conterá o início da string e RSI conterá a entrada do dicionario

    xor rax, rax                    ; zera rax
    .loop:
        test rsi, rsi                   ; se RSI for nulo (primeira entrada) não há como buscar no dicionario
        jz .end
        push rdi                        ; salva RDI e RSI
        push rsi
        add rsi, 8                      ; agora RSI aponta para 8 posições na frente pois nossa estrutura é do estilo:

        ;   dq anterior: XXXX   ; como é uma quadword (dq), ao adicionar 8 ao RSI, apontaremos para o "nome" no inicio da string
        ;   db "nome", 0

        call string_equals      ; chama string_equals para comparar as strings
        pop rsi                 ; recupera RSI e RDI
        pop rdi                 
        test rax, rax           ; verifica se string_equals deu que são iguais
        jnz .found              ; se forem, vai para .found
        mov rsi, [rsi]          ; caso contrário, RSI agora vai apontar para o que está no início do conteúdo de rsi [RSI + 0] que é justamente a posição anterior da memória

        ;   dq anterior: XXXX   ; RSI[0] = === [RSI] = XXXX é o a posição de memória anterior
        ;   db "nome", 0

        jmp .loop
    
    .found:
        mov rax, rsi            ; retorna a posição no dicionário

    .end:
        ret
```

Esse código é meio complexo. Atenção para os seguintes detalhes:

1. RSI aponta para o início da "struct" da lista ligada. Logo, [RSI] na verdade aponta para a posição da memória anterior vinda do nosso macro.
2. Como essa posição de memória anterior está em "quadword" - dq -, RSI + 8 representa RSI + 8 bytes passaria para a próxima entrada do nosso macro (que é justamente o início da string)

Criaremos o dicionário em `words.inc`:

```asm
colon "hey", hey
db "hoho",0

colon "test", test
db "hihi", 0

colon "tost", tost
db "haha", 0
```

Finalmente, na nossa `main.asm`, criaremos uma função `_start` simples que:

- Lerá uma string de entrada em um buffer de 255 caracteres, no máximo
- Tentará encontrar essa string no nosso dicionário e retornará o valor correspondente ao exibido.

Com a nossa `main.asm`:

```asm
section .text
%include "colon.inc"

extern read_word
extern find_word
extern print_newline
extern print_string
extern print_error
extern string_length
extern exit

global _start

section .bss
input resb 255

section .rodata
msg_noword: db "Não achada", 0
err_read: db 'Erro ao ler', 0

%include "words.inc"
    
section .text

_start:
    mov     rdi, input      ; endereço do buffer
    mov     rsi, 255        ; tamanho máximo do buffer
    call    read_word       ; lê o buffer e coloca em "input"

    mov     rdi, input      ; buffer com a palavra lida
    mov     rsi, pp         ; ponteiro do dicionário (pp foi definido no nosso macro)
    call    find_word       ; procura a entrada do dicionario correspondente

    test    rax, rax
    jz      .no_find        ; caso a entrada seja nula, não achou
                            ; caso contrário, RAX está apontando para o inicio do struct:

                            ; colon {
                            ;   *prev_position - 8 bytes
                            ;   string name
                            ;  }
                            ;   
                            ;   ** Outros códigos abaixo **
                            ;
                            ;

                            ; logo, o raciocínio é, agora com o ponteiro para o "prev_position", acharmos o final da string "name" para que 
                            ; possamos acessar o código após ela

    add     rax, 8          ; ajusta para pular o cabeçalho do dicionário (onde está o início da string name)
    mov     rdi, rax        ; rdi = endereço do nome
    call    string_length   ; acha o tamanho do nome para que o RDI aponte para o final da struct
    add     rdi, rax        ; rdi = colon[final]
    inc rdi                 ; rdi = colon[final + 1] = OUTROS CÓDIGOS - poderiamos colocar RIP apontando para ele, por exemplo
    call    print_string    ; printamos o que está abaixo do cólon
    jmp     .end

.no_find:
    mov     rdi, msg_noword
    call    print_string

.end:
    call    exit
```

Pontos de destaque estão no código. Principalmente o método de achar o tamanho inteiro da struct "colon"
