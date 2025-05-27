# Capitulo 6 

"Interrupções e chamadas de sistema". Neste capítulo, vamos abordar as `syscalls`, artifícios importantes para a operação do sistema como um todo.

## 6.1 Entrada e saída

Além da necessidade de chamadas de sistema para a interpretação de entrada e saída (E/S), é necessário outro recurso para que possamos nos comunicar com dispositivos externos. Esse recurso são as portas de E/S. Elas podem ser acessadas das seguintes formas:

1. Por meio de um endereçamento separado: 2^16 portas de 1 byte cada variando de 0 a 0xFFFF. Os comandos `in` e `out` são usados para troca de dados entre as portas e o EAX. Suas permissões são controladas verificando:
    - O campo IOPL (I/O Privilege Level) do registrador `rflags`
    - O mapa de bits de I/O Permission de um *Task State Segment* (que será visto em 6.1.1)

2. Por meio de E/S mapeada em memória: Uma parte do endereçamento é especificamente mapeada para prover interação com dispositivos externos que respondam omo componentes de memória. Depois disso, instruções de endereçamento de memória podem ser usadas para manipular a E/S desses dispositivos (usam segmentação e proteção de páginas para essas tarefas).

O campo IOPL do registrador `rflags` funciona da seguinte maneira: se o nível atual de privilégio for menor ou igual ao IOPL, as seguintes instruções poderão ser executadas:

- `in` e `out` (E/S usuais)
- `ins` e `outs` (E/S de strings)
- `cli` e `sti` (limpeza/ativação da flag de interrupção)

Por isso, ao configurar o IOPL manualmente, podemos modificar a forma que ela escreve para a saída. Além disso, na arquitetura Intel 64 é possível detalhar os bits que correspondem a cada dispositivo de E/S para determinar a porta a ser usada.

O mapa de bits de permissÕes de E/S faz parte do TSS (Task State Segment), que é uma entidade única por processo. 

### 6.1.1 O registrador TR e o Task State Segment

Aqui o autor faz uma breve explicação sobre o uso do TR e do TSS em modo longo (não modo protegido). Confesso que não entendi muito bem.

A função do registrador TR é armazenar o seletor de segmento para o descritor TSS, que reside na GDT (Global Descriptor Table). Assim como os outros registradores de segmento, o TR possui um registrador sombra (_shadow register_ - que prepara valores para serem chamados no futuro pelos demais registradores) que é atualizado a partir da GDT quando o TR é atualizado (intrução `ltr`).

O TSS é a região da memória que armazena dados sobre alternância de tarefas a partir de uma tarefa que use um dispositivo de hardware. Há apenas um TSS usado pelo SO, dado que ele é usado em modo longo (o TSS em modo protegido foi considerado obsoleto). 

Os primeiros 16 bits do TSS armazenam offset para Input/Output Port Permission Map (aqueles 2^16 bits). Ele armazena oito ponteiros para `IST` especiais (Interrupt Stack Table), além de ponteiros de pilha para diferentes aneis. Sempre que um nível de privilégio mudar, oa pilha será alterada de acordo. O valor do RSP será capturado a partir do campo de TSS correspondente (rsp ring0, ring1 e ring2).

## 6.2 Interrupções

Elas alteram o fluxo de um programa ao deixarem o sistema operacional tomar de conta do que é feito assim que ela é chamada. Toda interrupção possui o chamado `handler de  interrupção`, que faz parte do SO e que coordena o que a interrupção fará.

A Intel diferencia interrupções externas assíncronas de interrupções internas síncronas, mas ambas são tratadas do mesmo modo.

Quando a interrupção ocorrer, a CPU verificará o IDT (Interruptio Descriptor Table, da TSS), cujos endereço e tamanho são armazenados no `idtr` (80 bits):

- [79:16] = Endereço da IDT (64 bits)
- [15:0] = Tamanho da IDT (16 bits)

Cada IDT ocupa 16 bytes em que a N-ésima entrada corresponde à N-ésima interrupção. Cada IDT é feita da seguinte maneira (4 trechos de 32 bits):

1. [31:0], sempre 0 (reservado)
2. [31:0], endereço do handler bits [63:32]
3. [32:16], endereço do handler bits [31:16]; 
    [15], P;
    [14:13], DPL;
    [12], 0;
    [11:8], tipo;
    [7:2], 00000;
    [1:0], IST
4. [31:16], seletor de segmento;
    [15:0], endereço do handler bits [15:0]

* Se o DPL for menor ou igual ao DPL atual, é possível chamar a instrução `int` (interrupt).
* O tipo pode ser 1110 (Gate de interrupção, IF - interrupt flag - será autoamticamente limpa pelo handler) ou 1111 (Gate de trap, IF não será limpa)

As primeiras 30 interrupções são reservadas, impossibilitando que possamos criar nossos próprios handlers para ela. 

* Se IF está ativa (em `rflags`), a interrupção será tratada. Caso contráriom será ignorada.

O autor explica que, apesar dos códigos de aplicações serem executados em baixos níveis de privilégio, o controle direto de dispositivos ocorre apenas em níveis altos de privilégio. Logo, quando ocorre uma interrupção com dispositivos, o handler eleva o nível de privilégio do programa para que possam ser executadas as devidas interrupções.

A pilha será modificada respectivamente. Se o IST for 0, `ss` será carregado com 0 e o novo RSP será carregado de TSS, o campo RPL do `ss` será configurado com o nível apropriado de privilégio e os antigos `ss` e `rsp` são salvos na nova pilha.

Para IST configurado com um dos 7 ISTs definidos em TSS, ele será usado.

Há também uma instrução `int` especial que aceita o número da interrupção, que chama um handler de interrupção manualmente. A flag IF é ignorada e o hanlder será chamado. Para coordenar essa execução de modo privilegiado, há um DPL.

Antes da interrupção ser propriamente tratada, os registradores `ss`, `rsp`, `rflags`, `cs` e `rip` são salvos na pilha. 

Pode ser que um handler precise de um *código de erro da interrupção* para que ele saiba propriamente como tratá-la. Algums códigos são:

| Vetor | Mnemônico               | Descrição Resumida                                                                 |
|-------|-------------------------|------------------------------------------------------------------------------------|
| 0     | Divide Error            | Divisão por zero ou estouro em instruções DIV/IDIV.                               |
| 1     | Debug Exception         | Exceção de debug, usada por pontos de parada e rastreamento.                      |
| 2     | Non-maskable Interrupt  | Interrupção não-mascarável, geralmente usada para eventos críticos de hardware.   |
| 3     | Breakpoint              | Interrupção de breakpoint, usada por debuggers (INT3).                            |
| 4     | Overflow                | Ocorrência de overflow detectado com INTO.                                        |
| 5     | Bound Range Exceeded    | Verificação de limite (instrução BOUND).                                          |
| 6     | Invalid Opcode          | Instrução inválida ou indefinida para a CPU.                                      |
| 7     | Device Not Available    | Instrução de ponto flutuante sem coprocessador disponível (FPU).                  |
| 8     | Double Fault            | Falha ao processar uma exceção durante o tratamento de outra.                     |
| 9     | Coprocessor Segment Overrun | Obsoleto, usado antigamente para erros do coprocessador.                    |
| 10    | Invalid TSS             | TSS inválido ao realizar uma troca de tarefa.                                     |
| 11    | Segment Not Present     | Segmento referenciado não está presente na memória.                               |
| 12    | Stack Segment Fault     | Erro no segmento de pilha (SS).                                                   |
| 13    | General Protection Fault| Violação geral de proteção, acesso ilegal à memória ou instrução privilegiada.    |
| 14    | Page Fault              | Falha de página ao acessar memória virtual não mapeada ou com permissão inválida. Usada no caso de swapping e para o mapeamento de arquivos|
| 15    | (Reservado)             | Reservado pela Intel, não deve ser usado.                                         |
| 16    | x87 Floating-Point Exception | Erro na execução de instruções de ponto flutuante x87.                       |

Os depuradores usam bastante das interrupções como #BP. Se a TF (trap flag) estiver ativa em `rflags`, a interrupção será executada depois de **cada** instrução ser executada (execução instrução a instrução).

O fluxo de execução da N-ésima interrupção é:

1. O endereço da IDT é obtido a partir do `idtr`
2. O descritor da interrupção é localizado começando por 128*N-ésimo byte da IDT
3. O seletor de segmento e o endereço do handler são carregados em `cs` e `rip` a partir da IDT. Os antigos `ss`, `rsp`, `rflags`, `cs` e `rip` são salvos na pilha
4. Para certas interrupções um código de erro é inserido no topo da pilha do handler
5. Se o campo `type` (tipo) defini-lo com Interrupt Gate (1110), a flag IF será limpa. Se for Trap Gate (1111) ela não será limpa.

O autor menciona que, se a instrução não zerar a IF depois que o handler iniciar, não temso garantia que a próxima instrução ocorra sem interrupção.

O handler de interrupção é encerrado com `iretq` que restaura os registradores salvos na pilha.

## 6.3 Chamadas de sistema

Pode ser executada com `int 0x80`. No Intel 64 usa-se `syscall` e `sysret` para implementar chamadas de sistema. Seu mecanismo tem os seguintes atributos:

- A transição de aneis de proteção só pode ocorrer entre ring0 e ring3, pois quase não se usa ring1 e ring2.
- Os handlers de interrupção diferem, mas todas as chamadas são tratadas pelo mesmo código.
- Alguns registradores de propósito geral são implicitamente usados pela `syscall`
    - RCX, para armazenar o valor de RIP
    - R11, para armazenar o valor de RFLAGS

### 6.3.1 Registradores específicos de modelo

Quando uma nova CPU é criada, podem existir registradores que as outras CPUs não possuiam. Os MSR (Model-Specific Registers) são esses registradores. Usa-se os comandos `rdmsr` para lê-los e `wrmsr` para escrevê-los. Eles usam como base o número de indentificação do registrador. 

- `rdmsr` aceita o número de MSR em ECX e devolve o valor do registrador em EDX:EAX
- `wrmsr` aceita o número de MSR em ECX e lá armazena o valor do registrador em EDX:EAX

### 6.3.2 syscall e sysret

A instrução `syscall` depende de vários MSR:

- STAR (MSR número 0xC0000081) armazena dois pares de valores `cs` e `ss` para o handler da chamada de sistema `sysret`:
    - [63:48] sysret cs:ss
    - [47:31] syscall cs:ss
    - Resto: inutilizado

- LSTAR (MSR número 0xC0000082) armazena o endereço do handler da chamada de sistema (novo RIP)
- SFMASK (MSR número 0xC0000084) mostra quais bits em `rflags` devem ser limpos no hander da `syscall`

A `syscall` tem o seguinte fluxo:

- carrega CS a partir de STAR
- altera RFLAGS com base em SFMASK
- salva RIP em RCX
- Inicializa RIP com o valor de LSTAR e obtém novos CS e SS de STAR

* O RIP sempre deve mudar para que a interrupção ocorra

- Por fim, `sysret` carrega CS e SS a partir de STAR, e RIP de RCX

A mudança de CS e SS provoca uma mudança no seletor da GDT e do seu `shadow register`, mas quando é para uma `syscall`, essa mudança não ocorre.

O autor detalha os valores do registrador sombra do CS e do CPL, mas não vi tanta importância em mostrá-los.



