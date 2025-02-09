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