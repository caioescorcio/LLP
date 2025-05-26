%define i 1

%define d i * 3
%xdefine xd i * 3
%assing a i * 3

mov rax, d
mov rax, xd
mov rax, a

%define i 100

mov rax, d
mov rax, xd
mov rax, a