# Extract base name (remove .asm extension)
filename="${1%.asm}"

# Assemble with NASM
nasm -f elf64 "$filename.asm" -o "$filename.o"

# Link with ld
ld -m elf_x86_64 "$filename.o" -o "$filename.exe"

./"$filename.exe"