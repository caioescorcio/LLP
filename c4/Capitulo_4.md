# Capitulo 4 

Este capítulo aborda o modo de implementação da virtualização da memória do Intel 64.

## 4.1 Caching

O conceito de caching é diretamente relacionado à proximidade de memória ao processador quando comparada aos outros níveis de memória. Disco é maior que a RAM e, logo, é mais difícil de se manusear. A RAM é maior que a Cache e, logo, é mais lenta. A Cache é o nível de memória mais rápida, cara e próxima ao processador, por isso é importante.

Vale mencionar que o disco rígido também tem cache próprio e, em relação ao processador, existem diversos níveis de cache (L1, L2, e L3), que também obedecem certa hierarquia de velocidade/tamanho, se aproximando até aos próprios registradores. Além disso, as CPUs tem sempre, no mínimo um cache de instrução e um Translation Lookaside Buffer (buffer de tradução de endereço) para melhorar o desempenho da memória virtual.

A abstração de Cache é um nível de memória auxiliar mais rápida para uma memória inicial.

O uso da Cache é relacionada ao conceito de Princípio da Localidade (que diz que geralmente, um acesso à memória é seguido de acessos de memória em posições adjacentes). A Cache permite a memória virtual utilizar a memória física para porções de instruções.

## 4.2 Motivação

A execução multi-tarefa/paralelizada de instruções requer determinados desafios:

- Executar programas de tamanhos arbitrários (carregamento de apenas parte de um programa no futuro próximo)
- Ter vários programas na memória ao mesmo tempo (programas de interação com dispositivos, etc) e alternância entre programas
- Armazenar programas em qualquer lugar da memória física (permitindo a alocação de qualquer posição da memória, mesmo com endereçamento absoluto)
- Livrar programadores de tarefas de memória o máximo possível
- Ter eficiência para compartilhamento de dados e códigos compartilhados

## 4.3 Espaços de endereçamento

Um _espaço de endereçamento_ é um intervalo de endereços, que pode ser de dois tipos:

- O endereço físico: usado para acessar bytes do hardware. Ele deve obedecer o tamanho da memória física e os espaços já alocados (ou proibidos)
- o endereço lógico: uma forma de endereço virutal em que o programador vê a posição de memória como visto no código (ex: `mov rax, [0x10bfd]`, em que o endereço lógico é [0x10bfd] - que não é seu endereço físico - e está visível ao programador). Vale mencionar que esse endereço corresponde a um endereço físico virtualizado e, portanto necessita de uma MMU (Memory Management Unit) para a tradução de endereços lógicos (virtuais) para endereços físicos.





