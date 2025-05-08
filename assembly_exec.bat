nasm -f elf64 -o %~n1.o "%1"

ld -o %~n1.exe %~n1.o "C:\msys64\ucrt64\lib\libkernel32.a" "C:\msys64\ucrt64\lib\libmsvcrt.a"

cls

%~n1.exe