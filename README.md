# LLP
Respositório de estudo do livro Programação em Baixo Nível, do Igor Zhirkov. Nele se encontra um estudo aprofundado de Assembly e de C. O objetivo inicial desse respositório, assim como os demais de livros, é gerar uma base de conteúdo para o estudo de quem se interessar sobre esse tópico

## Estrutura do respositório

Em cada capítulo ou subcapítulo existirão pastas que abordarão conceitos e métodos de código usados no livro. A organização de pastas está na seguinte maneira:

```
.\LLP
  |- \c1
    |- \codigos
    |- Capitulo_1.md
  |- \c2
    |- \codigos
    |- Capitulo_2.md
```

Para a "criação de um novo capítulo" execute o `novo_capitulo.bat`. Eventualmente podem existir alguns `.md` a mais e outras divisões dentro de `.\codigos`, mas isso era previsto dada a densidade do livro.

Para utilizar ASM no Windows, é necessário o MinGW. Para fazer o download e setup, leia a [documentação](https://code.visualstudio.com/docs/languages/cpp)

Para a execução dos arquivos ASM no Windows, será usado um script Windows chamado `assembly_exec.bat`. Com ele, geraremos o código objeto do nosso assembly e, em seguida, criaremos um executável:

```bat
nasm -f win64 -o %~n1.obj "%1"

ld -o %~n1.exe %~n1.obj "C:\msys64\ucrt64\lib\libkernel32.a" "C:\msys64\ucrt64\lib\libmsvcrt.a"

cls

%~n1.exe
```

Uso: `assembly_exec.bat cX\codigos\<ASSEMBLY>`

Para uso no Linux (como é feito no livro), existe o script `assembly_exec.sh`:

```bash
#!/bin/bash

# Verifica se um arquivo foi passado como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 arquivo.asm"
    exit 1
fi

# Remove a extensão .asm para usar como nome base
BASENAME="${1%.asm}"

# Compila o arquivo Assembly
nasm -f elf64 -o "$BASENAME.o" "$1"

# Linka o objeto para gerar o executável
ld -o "$BASENAME.exe" "$BASENAME.o"

# Limpa a tela (opcional)
clear

# Executa o programa gerado
"./$BASENAME.exe"
```

Uso, no WSL/Linux: `assembly_exec.sh cX/codigos/<ASSEMBLY>`