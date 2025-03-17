# Trabalho - subconjunto do Pascal

Construir um compilador de um subconjunto da linguagem Pascal, definido abaixo, para a representação intermediária do LLVM ([LLVM-IR](https://llvm.org/docs/LangRef.html), ou LLVM Assembly Language).
Utilize a versão 15 ou superior do LLVM, onde [*Opaque Pointer*](https://llvm.org/docs/OpaquePointers.html) são suportados por padrão, preferencialmente use a versão 19.

Recursão e passagem por referência são permitidas. As funções `read` e `write` devem ser providas pelo compilador, e podem ser substituídas por uma chamada ao scanf e printf. Não é necessário ler e imprimir caracteres na tela, trabalhe apenas com números inteiros e de ponto flutuante. Mais detalhes em como usar/chamar essas funções pode ser obtido [aqui](./read_write_llvm.md).

A gramática não permite a construção com apenas IF-THEN, impedindo o problema de *dangling else*. Portanto, toda construção de condicional deve conter tando os enunciados do THEN como do ELSE.

Outro ponto é que não existe uma distinção sintática entre uma variável simples e uma chamada de função sem parâmentos. Ambos são gerados pela produção `FATOR: ID`.

## Exemplos de código

Alguns exemplos de código podem ser vistos [aqui](./exemplos_pascal).

## Gramática

A seguinte gramática já está apropriada para o Bison:

```
PROGRAMA: PROGRAM ID ABRE_PARENTESES LISTA_DE_IDENTIFICADORES FECHA_PARENTESES PONTO_VIRGULA
        DECLARACOES 
        DECLARACOES_DE_SUBPROGRAMAS 
        ENUNCIADO_COMPOSTO 
        PONTO_FINAL
        ;

LISTA_DE_IDENTIFICADORES: ID 
                        | LISTA_DE_IDENTIFICADORES VIRGULA ID 
                        ;

DECLARACOES: DECLARACOES VAR LISTA_DE_IDENTIFICADORES DOIS_PONTOS TIPO PONTO_VIRGULA 
           | /* empty */ 
           ;

TIPO: INTEIRO
    | REAL 
    ;

DECLARACOES_DE_SUBPROGRAMAS: DECLARACOES_DE_SUBPROGRAMAS DECLARACAO_DE_SUBPROGRAMA PONTO_VIRGULA
                           | /* empty */
                           ;

DECLARACAO_DE_SUBPROGRAMA: CABECALHO_DE_SUBPROGRAMA DECLARACOES ENUNCIADO_COMPOSTO 
                         ;

CABECALHO_DE_SUBPROGRAMA: FUNCTION ID ARGUMENTOS DOIS_PONTOS TIPO PONTO_VIRGULA 
                        | PROCEDURE ID ARGUMENTOS PONTO_VIRGULA 
                        ;

ARGUMENTOS: ABRE_PARENTESES LISTA_DE_PARAMETROS FECHA_PARENTESES
          | /* empty */
          ;

LISTA_DE_PARAMETROS: LISTA_DE_IDENTIFICADORES DOIS_PONTOS TIPO 
                   | VAR LISTA_DE_IDENTIFICADORES DOIS_PONTOS TIPO 
                   | LISTA_DE_PARAMETROS PONTO_VIRGULA LISTA_DE_IDENTIFICADORES DOIS_PONTOS TIPO 
                   | LISTA_DE_PARAMETROS PONTO_VIRGULA VAR LISTA_DE_IDENTIFICADORES DOIS_PONTOS TIPO 
                   ;

ENUNCIADO_COMPOSTO: BEGIN_TOKEN ENUNCIADOS_OPCIONAIS END
                  ;

ENUNCIADOS_OPCIONAIS: LISTA_DE_ENUNCIADOS
                    | /* empty */
                    ;

LISTA_DE_ENUNCIADOS: ENUNCIADO
                   | LISTA_DE_ENUNCIADOS PONTO_VIRGULA ENUNCIADO
                   ;

ENUNCIADO: VARIAVEL OPERADOR_ATRIBUICAO EXPRESSAO
         | CHAMADA_DE_PROCEDIMENTO
         | ENUNCIADO_COMPOSTO
         | IF EXPRESSAO THEN ENUNCIADO ELSE ENUNCIADO
         | WHILE EXPRESSAO DO ENUNCIADO 
         ;

VARIAVEL: ID 
        ;

CHAMADA_DE_PROCEDIMENTO: ID
                    | ID ABRE_PARENTESES LISTA_DE_EXPRESSOES FECHA_PARENTESES
                    ;

LISTA_DE_EXPRESSOES: EXPRESSAO
                   | LISTA_DE_EXPRESSOES VIRGULA EXPRESSAO
                   ;

EXPRESSAO: EXPRESSAO_SIMPLES
         | EXPRESSAO_SIMPLES OPERADOR_RELACIONAL EXPRESSAO_SIMPLES
         ;

EXPRESSAO_SIMPLES: TERMO
                 | SINAL TERMO  
                 | EXPRESSAO_SIMPLES MAIS EXPRESSAO_SIMPLES 
                 | EXPRESSAO_SIMPLES MENOS EXPRESSAO_SIMPLES 
                 | EXPRESSAO_SIMPLES OR EXPRESSAO_SIMPLES 
                 ;

TERMO: FATOR
     | TERMO OPERADOR_MULTIPLICATIVO FATOR
     ;

FATOR: ID
     | ID ABRE_PARENTESES LISTA_DE_EXPRESSOES FECHA_PARENTESES
     | NUM 
     | ABRE_PARENTESES EXPRESSAO FECHA_PARENTESES 
     ;

SINAL: MAIS
     | MENOS 
     ;
```

### Tokens terminais -> lexemas correspondentes ou padrão

| Token | Lexema |
| ----- | ------ |
| PROGRAM | program|
| ID | `[a-zA-Z][a-zA-Z1-9]*` |
| PONTO\_FINAL | . |
| VAR | var |
| INTEIRO | integer |
| REAL | real |
| FUNCTION | function |
| PROCEDURE | procedure |
|ABRE\_PARENTESES | ( |
| FECHA\_PARENTESES | ) |
| PONTO\_VIRGULA | ; |
| DOIS\_PONTOS| : |
| BEGIN\_TOKEN | begin |
| END | end |
| IF | if |
| THEN | then |
| ELSE | else |
| WHILE | while |
| DO | do |
| OPERADOR\_ATRIBUICAO | := |
| OPERADOR\_RELACIONAL | =, <>, >, >=, <, <= |
| MAIS | + |
| MENOS | - |
| OR | or |
| OPERADOR\_MULTIPLICATIVO | \*, /, div, mod, and |
| NUM | `[0-9]+(.[0-9]+)?([Ee][+-]?{digitos})?` |

Obs.: a vírgula não faz parte dos lexemas de OPERADOR\_RELACIONAL e OPERADOR\_MULTIPLICATIVO, mas apenas divide os lexemas que podem ser classificados como um token de cada tipo.
