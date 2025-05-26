%define pp 0                                    ; inicia o dicionario na posicao zero

%macro colon 2                                  ; macro com dois argumentos
%%pp: dq pp                                     ; cria um label único (%%) para uma quad-word do que estava na posição anterior
db %1, 0                                        ; armazena o valor da string finalizada em zero

x_%+ %2:                                        ; inicia o código para a próxima função (note que é usado um "%+ " para aglutinar strings)

%define pp %%pp                                 ; 'incremento' do valor da posição passada para uma nova posição usando a sua label

%endmacro