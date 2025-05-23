# Capitulo 2 

## Linguagem Assembly

## 2.1 Configurando o ambiente

O autor mostra as configurações que ele disponibilizou para a execução dos códigos em ASM (Assembly) e em C. No [site da NASM](https://www.nasm.us/) há o download do compilador de Assembly que será utilizado.

### 2.1.1 Trabalhando com os códigos de exemplo

O autor fala sobre a utilização do [gdb](https://www.ic.unicamp.br/~rafael/materiais/gdb.html) para a depuração de códigos, quando necessária.

## 2.2 Escrevendo "Hello, world"

### 2.2.1 Entradas e saídas básicas

Pela ideologia Unix, tudo é um arquivo, ou seja, tudo é uma stream de bytes. Com eles é possível executar as mais fundamentais operações em um sistema operacional.

Nessa lógica, o racional por trás da execução de programas, em ambientes Unix no geral, é a abertura de um arquivo. Cada arquivo é identificado pelo seu *descritor*, que é um inteiro que o identifica. Eles são abertos pela syscall `open` que, por sua vez, inicia 3 outros arquivos para a execução do programa: `stdin`, `stdout` e `stderr`, que têm descritores *0*, *1* e *2*. Eles controlam o input, output e os erros na execução do dado programa. 

No padrão dos computadores atuais, o `stdin` está ligado ao teclado, enquanto o `stdout` está ligado ao terminal, logo, `stdout` deve ser escrito no terminal através da *syscall* de `write`.

O nosso primeiro código em ASM será, em `hello_world.asm`:

```asm
global _start

section .data
    message: db 'hello, world!', 10

section .text
_start:
    mov rax, 1          ; o número da syscall deve ser armazenada em rax
    mov rdi, 1          ; argumento #1 em rdi: onde devo escrever o (descritor)?
    mov rsi, message    ; argumento #2 em rsi: onde começa a string?
    mov rdx, 14         ; argumento #3 em rdx: quantos bytes devem ser escritos?
    syscall             ; faz a syscall, que tem a sua função dependente do valor de RAX
```

### 2.2.2 Estrutura do programa

Em linhas gerais, a explicação do código é:

- `global _start`, deixa a seção _start visível para o linker, definindo seu ponto de entrada.
- `section .data`, define uma seção dos dados a serem usados
    - `message: db 'hello, world!', 10`: 
        - message, é o nome da variável
        - db, significa "define byte", que armazena os bytes da string na memória
        - 'hello, world!', 10 é a concatenação da frase com o `10`, que é o ASCII do `\n`
- `section .text`, define a "função que estamos fazendo"
- `_start`, é onde o linker chamará a função do _start do código
    - `mov rax, 1`, coloca no RAX o tipo de syscall que será chamada caso o `syscall` seja chamado. Nesse caso, 1 é stdout
    - `mov rdi, 1`, coloca no RDI o destino de onde será escrito a mensagem
    - `mov rsi, message`, coloca o ponteiro para a string no RSI
    - `mov rdx, 14`, indica o tamanho da mensagem, 13 bytes de 'hello, world!' + 1 de `\n`
    - `syscall`, chama o stdout (RAX)

É importante ressaltar que o código feito é funcional para o ASM x86_64 para o Linux e não funcionará corretamente (devido ao uso do syscall) no Windows.

É importante falar que, uma vez que não há syscall de encerramento do programa, será indicado que está acontecendo *segmentation fault* no processo. Para solucionar esse problema, adicionaremos o seguinte comando ao final do código:

```asm
    mov rax, 60         ; syscall: sys_exit (60), que é o de EXIT
    xor rdi, rdi        ; Código de saída 0 em rdi, pois AAA XOR AAA é sempre 0
                        ; Código de saída 0 indica sucesso, enquanto outros valores indicam erros
    syscall             ; Chama o kernel para sair  
```

Falando agora um pouco sobre os dados em assembly, vale ressaltar que na seção `.data`, podemos usar várias diretivas sobre como faremos nossos dados:

- `db`, bytes
- `dw`, "palavras" (words, 2 bytes cada)
- `dd`, double words (4 bytes)
- `dq`, quadruple words (8 bytes)

Um exemplo de listagem de variáveis globais pode ser:

```asm
section .data
    ex1: db 5, 16, 8, 4, 2, 1   ; concatenação de 0x05  0x10  0x08  0x04  0x02  0x01    (6bytes)
    ex2: times 999 db 42        ; 0x2A 0x2A 0x2A ... (999 vezes)                        (999 bytes)
    ex3: dw 999                 ; 0xE7 0x03                                             (2 bytes)
```

Nesses casos, letras e dígitos são codificados como ASCII.

Vale ressaltar também alguns detalhes sobre como o ASM funciona:

- mov:
    - não pode copiar dados da memória para memória, só com registradores
    - os operandos de origem e de destino devem ter o mesmo tamanho total
- rax:
    - armazena syscall
- rdi, rsi, rdx, r10, r8 e r9:
    - usados pra armazenar argumentos de syscall
    - syscall não pode ter mais de 6 argumentos
- syscall:
    - modifica rcx e r11, explicação em outro capítulo
    - a syscall de `write` recebe 3 argumentos: descritor de arquivo (no caso o stdout), o endereço do buffer a ser escrito (rsi) e a quantidade de bytes a serem escritos (rdx)


Finalmente, o código "correto" de hello_world.asm seria:

```asm
section .data
message: db 'hello, world!', 10

section .text
global _start

_start:
    mov rax, 1;
    mov rdi, 1;
    mov rsi, message;
    mov rdx, 14
    syscall;

    mov rax, 60   ; sys_exit recebe apenas um argumento, o código de saída, além do RAX     
    xor rdi, rdi        
    syscall           
```

## 2.3  Exemplo: exibindo o conteúdo de registradores

Vamos fazer um código de leitura do conteúdo de alguns registradores...

```asm
section .data

codes:
    db  '0123456789ABCDEF'

section .text
global _start

_start:
    ; numero 1122... em hexadecimal
    mov rax, 0x1122334455667788 ; = 0001 0001 0010 0010 ... 1000 1000  

    mov rdi, 1   ; File descriptor 1 (stdout) para saida
    mov rdx, 1   ; Numero de bytes a escrever (cada caractere hexadecimal)
    mov rcx, 64  ; 64 bits no numero, usado para deslocamento

    ; 4 bits representam um dígito hexadecimal
    ; Use o descolamento (shift) e o AND lógico para isola-los
    ; O resultado desse AND é o 'offset' no array '.codes'

.loop:

    push rax                ; "aumenta" a fila e coloca o valor do ponteiro de RAX no topo da fila para pega-lo depois que fizermos cada iteracao no loop
    sub rcx, 4              ; subtrai rcx em 4. RCX só será zero se o loop for perpassado 16x (64 - 4x16 = 0)
    ; cl eh a parte menor do reg rcx: 
    ; rcx -- ecx -- cx -- ch + cl, cl sao os ultimos 8 bits de rcx, no caso, 64, 60, 58, ... a cada iteracao

    sar rax, cl             ; sar = shift arithmetic right - preserva o sinal, shifta RAX em cl
    and rax, 0xF            ; pega os ultimos 4 bits (pois 0xF = 1111) de rax. Isso faz com que passemos a cada caractere

    lea rsi, [codes + rax]  ; lea = LOAD EFFECTIVE ADDRESS, coloca em RSI o que a posição de 'codes' + a posição do que está em rax
                            ; nesse caso, se rax = 0010, teremos em RSI o ponteiro do inicio do array 'codes' + 2, representando o caractere '2'
    mov rax, 1              ; syscall de write

    ; syscall altera rcx e r11
    
    ; syscall altera RCX e R11, entao salvamos RCX temporariamente
    push rcx      
    syscall       ; Chamada de sistema: write(1, &char, 1)
    pop rcx       ; Restauramos RCX apos a syscall

    pop rax       ; recuperamos o RAX

    ; 'test' pode ser usado cono una verificacao rapida de se um numero eh 0
    
    test rcx, rcx   ; checamos se RCX chegou a 0
    jnz .loop       ; se nao, loop

    mov rax, 60
    xor rdi, rdi    ; finalizamos o programa
    syscall
```

Questão 14: Corretos
Questão 15: sar preserva o sinal e shr não preserva, puxa da posição de memória mais próxima ("acima")
Questão 16: Modificamos o modo de "tradução". Ao invés de compará-los a um array "codes", comparamos a outro tipo de estrutura

*Nota*: é importante lembrar de zerar os regs que se trabalha.


### 2.3.1 Rótulos locais

São os "nomezinhos" que usamos ao longo do código para rotular as partes de execução. O último rótulo global usado sem "." no início é a base para os rótulos subsequentes, por exemplo: ".loop" nesse caso é "_start.loop". Podemos usar essa referência para endereçar qualquer ponto do programa.

### 2.3.2 Endereçamento relativo

Isso leva em conta casos como o `lea`, ou até mesmo o `mov`:

- `mov rsi, rax` coloca o valor de rax em rsi.
- `mov rsi, [rax]` copia o conteúdo da memória ("8 bytes em sequência", para 64 bits, já que o mov leva em conta os tamanhos dos dois operandos como iguais), a partir do endereço no colchete. Esses colchetes são *endereçamentos indiretos*.

Como dito, `lea` significa "load effective address", que representa uma forma de "fazer o mov com argumentos diversos", podendo realizar operações no comando. No caso usado (`lea rsi, [codes + rax]`), o ponteiro estaria apontando para a posição a partir do primeiro digito de codes[rax], e, uma vez que RDI estava em 1, seria printado apenas 1 caractere.

Nesse caso:

- `lea rsi, [codes + rax]` é o mesmo que: 
    - `mov rsi, codes`
    - `add rsi, rax`

### 2.3.3 Ordem de execução

Todos os comandos são executados de maneira consecutiva, exceto nos casos de jumps. A instrução de jump incondicional (`jmp`) pode ser substituida por `mov rip, addr`, onde addr é um endereço arbitrário e `rip` é o PC. Os jumps dependem das `rflags`, que são geradas a partir de outros comandos. Por exemplo, `test` e `cmp` geram flags de comparação dos valores de dois registradores, sendo usados em união aos jumps. `cmp` subtrai o segundo operando do primeiro mas não salva o valor em lugar nenhum, ativando apenas as flags. `test` faz praticamente a mesma coisa, mas com um AND lógico no lugar.

Ex: `test rcx, rcx` é rcx AND rcx, que só é 0 se *rcx == 0*.

Os jumps mais comuns são:

- `jF`: onde F é uma flag. No exemplo `jnz` é para a flag `nz` que é "not zero"
- `ja`/`jb`: jump if above e jump if below - para um jump depois de um `cmp` unsigned
- `jg`/`jl`: jump if greater e jump if lower - para comparação com sinal
- `jae`/`jle`: jump if above or equal e jump if less or equal - intuitivo.

Questão 17: `je` é jump if equal, `jz` é jump if zero.

## 2.4 Chamadas de função

Seguindo a lógica esperada, a chamada de função na realidade ocorre por meio de um "`push` and `jmp`", como da seguinte forma:

```asm
push rip ; salva o PC da instrução "atual"
jmp <ENDEREÇO>  ; chama outra rotina

; isso tudo equivale a um:

call <ENDEREÇO>
```

O `rip` fica salvo como endereço de retorno e, dessa forma, é usado para quando a rotina sair de sua execução. 

O autor fala que cada função pode receber "infinitos" argumentos, mas os 6 primeiros argumentos a serem passados são `rdi`, `rsi`, `rdx`, `rcx`, `r8` e `r9`, respectivamente. O restante é passado na pilha em ordem inversa.

O final de execução de uma função não é claro, mas a instrução `ret` simboliza o final da função, já que equivale a um `pop rip`. GARANTA QUE RIP ESTEJA NA PONTA DA FILA. Ela deve ser administrada com cuidado.

Existem funções que alteram (obviamente) o conteúdo dos registradores. Eis uma distinção:

- Regs callee-saved: salvos por quem é chamado. Devem ser salvos/restaurados ainda durante a execução da função, eles são `rbx`, `rbp`, `rsp`, `r12-15`.
- Regs caller-saved: salvos por quem chama. Devem salvos antes da execução da função e salvos depois. Não é necessário que isso seja feito ao longo da execução. São os demais regs.

A conveção geral é:

- Salvar e restaurar os callee-saved.
- Estar ciente que os caller-saved são passíveis de modificação.

Via de regra, além de tudo isso, o registrador `rax` é usado como endereço de retorno das funções, sendo ele retornado (seja via syscall ou via outros métodos) antes do fim da função (`ret`). Caso sejam retornados 2 valores, usa-se `rdx`.

Essas convenções servem para que as alterações feitas em uma função sejam transparentes ao programador, facilitando o seu uso. Cuidado, pois algumas `syscall`s devolvem valores também!

Não usei `rbp` nem `rsp`, pois eles são implicitamente usados durante a execução (ponteiros de pilha).

Agora, faremos um código `print_call.asm`, em que haverá funções do tipo `print_newline` e `print_hex`:


```asm
section .data

newline_char: db 10
codes: db '0123456789ABCDEF'

section .text
global _start

print_newline:

    mov rax, 1              ; para um syscall de stdout
    mov rdi, 1              ; para um destino de output (FD, arquivo) 1 (terminal)
    mov rdx, 1              ; para indicar que eh 1 caractere
    mov rsi, newline_char   ; para indicar a mensagem
    syscall
    ret

print_hex:

    mov rax, rdi            ; coloca rdi em rax, RDI sera o nosso arguemnto
    
    mov rdi, 1              ; para um destino de output (FD, arquivo) 1 (terminal)              
    mov rdx, 1              ; para indicar que eh 1 caractere
    mov rcx, 64             ; mesmo esquema de prin_rax.asm    
    
iterate:
    push rax                ; salva rax, pois o modificaremos no syscall
    sub rcx, 4              ; iteracao de 4 em 4 ate 64
    sar rax, cl             ; shift de rax em cl (60, 58...)
    and rax, 0xf            ; filtra apenas o ultimo caractere
    lea rsi, [codes + rax]  ; coloca em rsi ("ponteiro de print") o que representaria, o offset de codes em caracteres

    mov rax, 1              ; stdout

    push rcx                ; syscall altera rcx, devemos salva-lo  
    syscall                 ; rax = 1 (31, identificador de write)
                            ; rdi = 1 (stdout)
                            ; rsi = endereco do caractere (codes + offset)
    pop rcx
    pop rax
    test rcx, rcx
    jnz iterate             ; recuperacao de valores + loop

    ret

_start:
    call print_newline      ; nao esqueca que print_newline modifica rdi
    mov rdi, 0xCA10E5C04C10
    call print_hex
    call print_newline
    call print_newline

    mov rax, 60
    xor rdi, rdi
    syscall

```

As explicações estão ao longo do código


## 2.5 Trabalhando com dados

### 2.5.1 Endianess

Essa parte do livro na verade é uma forma de diferenciar números *big endian* de números *little endian*, que são duas convenções que os processadores adotam para realizar sua operações.

- Big Endian: números com vários bytes são armazenados na memória começando dos bytes mais significativos 
- Little Endian: números com vários bytes são armazenados na memória começando dos bytes menos significativos

Veja a tabela:

| Representação | Bytes Individuais |
|--------------|----------------|
| Big Endian   | `00 00 12 34`  |
| Little Endian | `34 12 00 00`  |

O Intel 64 é little endian, qque apresenta a vantagem do descarte dos bytes mais significativos de maneira mais eficiente, excluindo os endereços de memória "endereço + offset" para números seguidos de 0s até um determinado offset.

Big Endian geralmente é usado para pacotes de rede (ex: TCP/IP) e na JVM (Java Virtual Machine, para rodar códigos Java). Existe também o *Middle Endian*, mas não é muito utilizado.

### 2.5.2 Strings

Strings podem ser usadas ou colocando o seu tamanho de maneira explicita antes:

- `db 3, 'ola'`

Ou com um caractere de 'EOF', `0x0`:

- `db 'ola', 0`

### 2.5.3 Pré-processamento de constantes

Não é incomum ver códigos como:

```
x: 0

...

mov rax, x + 1 + 2*3
```

O NASM aceita esse tipo de expressão, com parenteses e até operações com bits, mas apenas com constantes conhecidas pelo compilador. Essas constantes são pré-processadas e não são calculadas em tempo de execução, tornando-se análogas à utilização de `add` ou `mul`.

### 2.5.4 Ponteiros e diferentes tipos de endereçamento

Se um ponteiro tem 8 bytes, faz sentido conseguirmos operar com os valores que ele representa para utilizar formas diferentes de dados, mas sempre deixando claro o tamanho dos números que estamos mexendo ou, pelo menos, como deduzí-lo. Veja os seguintes tipos de endereçamento:

```
mov rax, 10     ; endereçamento com o número direto: RAX agora "estará apontando para o número 10"
mov rax, rbx    ; endereçamento com o ponteiro de outro vetor: RAX aponta para o mesmo lugar que o RBX está apontando

mov r9, 10
mov rax, [r9]   ; endereçamento com o valor de outro vetor: RAX aponta para o endereço correspondente ao valor
                ; de 8 bytes a partir da posição em r9
                ; No banco de regs
                ; POS  VAL
                ; 0x0  0x00
                ; 0x1  0x00
                ; 0x2  0x00
                ; 0x3  0x00
                ; 0x4  0x00
                ; 0x5  0x00
                ; 0x6  0x00
                ; 0x7  0x00
                ; 0x8  0x00
                ; 0x9  0x00
                ; 0x10 0x00 rax aponta deste endereço para frente até chegar em 8 bytes (0x18) 
                ; 0x11 0x00
                ; ...


    
mov rax. [r9 + 4*rcx + 9]   ; endereçamento de "base + escala*indice + deslocamento", em que: 
                            ; a base é imediata (vinda do IMMGen) ou está um registrador
                            ; a escala só pode ser imediata e igual a 1, 2, 4 ou 8
                            ; o índice é imediato ou está um registrador
                            ; o deslocamento sempre é imediato
```

Para finalizar, falaremos da forma de endereçamento usando outros tipos de tamanhos de palavra. Em `addressing.asm`:

```asm
section .data
    test: dq -1  ; Definimos um valor inicial de teste = FFFFFFFFFFFFFFFF
    codes: db '0123456789ABCDEF' 

section .text
global _start

_start:
    mov byte[test], 1       ; colocamos no byte (little endian) começando no endereço de 'test' o numero 1: test = FFFFFFFFFFFFFF01
    ; mov word[test], 1     ; colocamos no word (little endian) começando no endereço de 'test' o numero 1: test = FFFFFFFFFFFF0001
    ; mov dword[test], 1    ; colocamos no dword (little endian) começando no endereço de 'test' o numero 1: test = FFFFFFFF00000001
    ; mov qword[test], 1    ; colocamos no qword (little endian) começando no endereço de 'test' o numero 1: test = 0000000000000001

    mov rax, [test]    

    ; Trecho reciclado de print_rax.asm

    mov rdi, 1 
    mov rdx, 1  
    mov rcx, 64 

.loop:
    push rax        
    sub rcx, 4      

    shr rax, cl     
    and rax, 0xF    

    lea rsi, [codes + rax] 

    mov rax, 1      
    push rcx        
    syscall         
    pop rcx         

    pop rax         

    test rcx, rcx   
    jnz .loop       

    
    mov rax, 60     
    xor rdi, rdi
    syscall

```

### 2.6 Exemplo: calculando o tamanho de uma string

Vamos iniciar a criação de funções em ASM com o pé direito. Primeiramente, vamos criar uma função que retorna um booleano "false" do terminal do shell ("retorna 1") no syscall. Em `false.asm`:

```asm
global _start

section .text

_start: 
    mov rdi, 1  ; "false" no shell significa 1 
    mov rax, 60 
    syscall 
```

Agora, vamos fazer uma função `strlen`, que no C calcula o tamanho de uma string. Para isso, usaremos a movimentação com vetores no ASM que vimos anteriormente. Em `strlen.asm`:

```asm
global _start

section .data

test_string: db "abcdefh", 0    ; A string deve terminar em 0 para que saibamos onde acaba o seu conteudo


section .text

strlen:             ; Por convencao, o primeiro e unico argumento a ser passado eh obtido por RDI

    xor rax, rax    ; RAX armazenara o tamanho da string. Se nao for zerado antes, seu valor 
                    ; sera aleatorio, por isso eh feito esse XOR

.loop:              ; Loop de execucao

    cmp byte [rdi+rax], 0   ; Verifica se, somado ao tamanho 'atual' medido da string, o byte visto 
                            ; a partir da posicao RDI eh nulo (EOL)

    je .end                 ; Se forem iguais, trata-se usando a funcao END 
    inc rax                 ; Se nao, incremento de RAX (funcao inc eh increment: RAX += 1)

    jmp .loop               ; Jump incondicional

.end:

    ret                     ; Quando 'ret'eh chamado, rax tera o valor de retorno

_start:

    mov rdi, test_string    ; RDI eh colocado como inicio da string de teste
    call strlen             ; Chama a funcao (note que nao usamos a pilha para isso)
    mov rdi, rax            ; RDI deixa de ser o valor visto pela string e passa a ser o argumento para o syscall

    mov rax, 60             ; syscall para finalizar
    syscall
```

Os bugs, no livro, do código da questão 19 (listagem 2.15) são que RAX não é zerado e que r13 deve ser restaurado na execução do código.

### 2.7 Exercício: biblioteca de entrada/saída

Agora criaremos uma lib similar à de stdio. As seguintes funções foram implementadas como os respectivos códigos em assembly e estão comentados ao longo dos códigos:

 - exit(): encerra o processo com um código de saída
    - Raciocínio: Apenas colocar em rdi (registrador de argumento) o valor desejado de exit code e chamar a função recebendo-o
 - strlen(): feita anteriormente
    - Raciocínio: basicamente passa pelos bytes de uma determinada posição de memória de um buffer é zero. Se sim, encerra o código, se não, incrementa uma variável de tamanho
 - print_char(): printa char
     - Raciocínio: Com o char colocado em RDI, salvamo-os e colocamos como valor de RSI para a execução da syscall de print
 - print_newline(): printa \n (feito em print_call)
     - Raciocínio: mesmo esquema de print_char com um "\n"
 - print_uint(): printa um inteiro de 8 bits sem sinal
     - Raciocínio: colocamos RDI (argumento) em RAX e apontamos com RSI (string de print) para o fim de um buffer que será printado. Com a função `div`, que divide RAX, passamos por um loop de divisões por 10 (em RCX) e, em seguida, adiciona-se o valor de byte do numero no que está sendo apontado por RSI
 - print_int(): printa um inteiro de 8 bits com sinal
     - Raciocínio: mesmo esquema de print_uint mas printando o caractere `-` e mudando o sinal do numero caso ele seja negativo
 - read_char(): le um caractere em stdin e o devolve
     - Raciocínio: é apenas umas syscall de stdin + print stdout
 - read_word(): recebe um endereço e um tamanho para ler uma palavra e a devolve
     - Raciocínio: passamos por um loop de leituras unitarias de caracteres para que eles sejam, um a um, armazenados em um buffer caso não sejam EOF ou NUL. Verificamos se eles são não nulos no processo. Para isso, usamos os vetores de RSP (com o auxílio de RAX) para manter-los em pilha
 - parse_uint(): recebe uma string terminada em nulo e tenta transforma-la em uma sequencia de uint
     - Raciocínio: passamos posição a posição de um RDI e convertemos os caracteres que são números no processo.
 - string_equals(): verifrica se duas strings são iguais
     - Raciocínio: verificamos o tamanho e comparamos vetores de mesma posição para verificar se seus valores em byte são iguais
 - string_copy(): copia uma string para outra
     - Raciocínio: mesmo esqumea de string_equals, mas com uma abordagem de cópia (mov)

As demais questões presentes no livro serão respondidas no mesmo.
