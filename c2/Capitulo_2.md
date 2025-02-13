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





