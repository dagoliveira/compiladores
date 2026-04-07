%{
#include <stdio.h>
#include <stdlib.h>
#include "compilador.h"

int yylex();
extern FILE *yyin;
extern int yylineno;
FILE *log_file, *out_file;

%}

%define parse.error detailed

// Tipo que cada simbolo gramatical pode assumir
//%union {
//    char *lexema;
//    ...
//}


%token INT FLOAT VOID RETURN WHILE
%token IGUAL MAIORIGUAL MENORIGUAL DIFERENTE
%token NUM ID 


%left '+' '-'
%left '*' '/'

%%

PROGRAMA: LISTA_DECLARACOES
        DECLARACORES_FUNCOES 
		;

LISTA_DECLARACOES: LISTA_DECLARACOES DECLARACAO
                 | /*empty*/
                 ;

DECLARACAO: TIPO LISTA_IDS ';'
           ;

TIPO: INT
    | FLOAT
    | VOID
    ;

LISTA_IDS: ID
            | LISTA_IDS ',' ID
            ;

DECLARACORES_FUNCOES: DECLARACORES_FUNCOES DECLARACAO_FUNCAO
                           | DECLARACAO_FUNCAO
                           ;

DECLARACAO_FUNCAO: TIPO ID '(' LISTA_ARGS ')' '{' LISTA_ENUNCIADOS '}' 
				 ;

LISTA_ARGS: TIPO ID
          | LISTA_ARGS ',' TIPO ID
          | /*empty*/
          ;

LISTA_ENUNCIADOS : ENUNCIADO
                 | LISTA_ENUNCIADOS ENUNCIADO
                 ;

ENUNCIADO: ID '=' EXPRESSAO_SIMPLES ';'
         | DECLARACAO 
         | RETURN EXPRESSAO_SIMPLES ';'
         | RETURN ';'
		 | WHILE '(' EXPRESSAO_RELACIONAL ')' '{' LISTA_ENUNCIADOS '}'
		 ;

EXPRESSAO_SIMPLES: EXPRESSAO_SIMPLES '+' EXPRESSAO_SIMPLES
         | EXPRESSAO_SIMPLES '-' EXPRESSAO_SIMPLES
         | EXPRESSAO_SIMPLES '*' EXPRESSAO_SIMPLES
         | EXPRESSAO_SIMPLES '/' EXPRESSAO_SIMPLES
         | FATOR
         ;

EXPRESSAO_RELACIONAL: EXPRESSAO_SIMPLES IGUAL EXPRESSAO_SIMPLES
					| EXPRESSAO_SIMPLES MAIORIGUAL EXPRESSAO_SIMPLES
					| EXPRESSAO_SIMPLES MENORIGUAL EXPRESSAO_SIMPLES
					| EXPRESSAO_SIMPLES DIFERENTE EXPRESSAO_SIMPLES
					| EXPRESSAO_SIMPLES '>' EXPRESSAO_SIMPLES
					| EXPRESSAO_SIMPLES '<' EXPRESSAO_SIMPLES
					;

LISTA_EXPRESSAO_SIMPLES: EXPRESSAO_SIMPLES
			   | LISTA_EXPRESSAO_SIMPLES ',' EXPRESSAO_SIMPLES
			   | /*empty*/
			   ;

FATOR: ID
	 | ID '(' LISTA_EXPRESSAO_SIMPLES ')'
     | NUM
     | '(' EXPRESSAO_SIMPLES ')'
     ;

%%

int main(int argc, char ** argv) {
    out_file = fopen ("output.ll", "w");
    log_file = fopen ("compilador.log", "w");
    fprintf(log_file, "Iniciando compilacao\n");
    if (argc == 2) {
		fprintf(log_file, "Lendo arquivo '%s'\n", argv[1]);
        yyin = fopen(argv[1], "r");
        yylineno=1;
        yyparse();
    } else if (argc == 1) {
		fprintf(log_file, "Lendo da linha de comando\n");
        yyparse();
    }
    fprintf(log_file, "Finalizando compilacao\n");
    fclose(out_file);
    fclose(log_file);
    return 0;
}

int yyerror(const char *s) {
  fprintf(stderr, "Erro na linha %d: %s\n", yylineno,s);
  exit(1);
  //return 0;
}

