# Capitulo 2 

## Linguagem Assembly

## 2.1 Configurando o ambiente

O autor mostra as configurações que ele disponibilizou para a execução dos códigos em ASM (Assembly) e em C. No [site da NASM](https://www.nasm.us/) há o download do compilador de Assembly que será utilizado.

### 2.1.1 Trabalhando com os códigos de exemplo

O autor fala sobre a utilização do [gdb](https://www.ic.unicamp.br/~rafael/materiais/gdb.html) para a depuração de códigos, quando necessária.

## 2.2 Escrevendo "Hello, world"

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
    syscall             ; Chama o kernel para sair  
```