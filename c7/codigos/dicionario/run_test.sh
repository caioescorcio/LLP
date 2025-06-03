#!/bin/bash
# filepath: c:\Users\caioe\Documents\Projetos\LLP\c7\codigos\dicionario\run_test.sh


# Monta todos os arquivos necessários
nasm -f elf64 -o test_dict.o test_dict.asm
nasm -f elf64 -o find_word.o find_word.asm
nasm -f elf64 -o cfa.o cfa.asm
nasm -f elf64 -o lib.o lib.asm

# Linka tudo em um executável
ld -o test_dict.exe test_dict.o find_word.o cfa.o lib.o

# Executa o teste
./test_dict.exe