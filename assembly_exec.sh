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
