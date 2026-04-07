%{
#include <stdio.h>
#include <stdlib.h>
#include "compilador.h"
#include "tipos.h"
#include "tabela_simbolos.h"

int yylex();
extern FILE *yyin;
extern int yylineno;
FILE *log_file, *out_file;

struct tabela_simbolos * tab_simbolos = NULL;
int escopo_atual = 0;
%}

%define parse.error detailed

%union {
    char *lexema;
    struct lista_simbolo * lista_s;
    Tipo tipo;
}


%token INT FLOAT VOID RETURN WHILE
%token IGUAL MAIORIGUAL MENORIGUAL DIFERENTE
%token <lexema>NUM <lexema>ID 

%type <lista_s>LISTA_IDS <lista_s>LISTA_ARGS
%type <tipo>TIPO

%left '+' '-'
%left '*' '/'

%%

PROGRAMA: LISTA_DECLARACOES
        DECLARACORES_FUNCOES  {
            fprintf(log_file, "Tabela de simbolos final\n");
            imprime_tabela_simbolos(log_file, tab_simbolos);
        }
        ;

LISTA_DECLARACOES: LISTA_DECLARACOES DECLARACAO
                 | /*empty*/
                 ;

DECLARACAO: TIPO LISTA_IDS ';' {atualiza_tipo_simbolos($2,$1); tab_simbolos = insere_simbolos_ts(tab_simbolos, $2); free_lista_simbolo($2);}
          ;

TIPO: INT {$$ = INTEIRO;}
    | FLOAT {$$ = REAL;}
    | VOID {$$ = VAZIO;}
    ;

LISTA_IDS: ID {$$ = insere_lista_simbolo(NULL, novo_simbolo($1, yylineno, VARIAVEL, escopo_atual, VAZIO));}
            | LISTA_IDS ',' ID {$$ = insere_lista_simbolo($1, novo_simbolo($3, yylineno, VARIAVEL, escopo_atual, VAZIO));}
            ;

DECLARACORES_FUNCOES: DECLARACORES_FUNCOES DECLARACAO_FUNCAO
                    | DECLARACAO_FUNCAO
                    ;

DECLARACAO_FUNCAO: TIPO ID {tab_simbolos = insere_simbolo_ts(tab_simbolos, novo_simbolo($2, yylineno, FUNCAO, escopo_atual, $1)); escopo_atual++;}
                 '(' LISTA_ARGS ')' {
                     struct simbolo *func = busca_simbolo(tab_simbolos, $2);
                     insere_func_args(func, $5);
                     tab_simbolos = insere_simbolos_ts(tab_simbolos, $5);
                     free_lista_simbolo($5);
                     fprintf(log_file, "Iniciando funcao '%s'\n",$2);
                 } 
                 '{' LISTA_ENUNCIADOS '}' {
                     imprime_tabela_simbolos(log_file, tab_simbolos); 
                     tab_simbolos = remove_simbolos(tab_simbolos, escopo_atual); 
                     escopo_atual--;
                     fprintf(log_file, "Finalizando funcao '%s'\n",$2);
                 }
                 ;

LISTA_ARGS: TIPO ID {$$ = insere_lista_simbolo(NULL, novo_simbolo($2, yylineno, VARIAVEL, escopo_atual, $1));}
          | LISTA_ARGS ',' TIPO ID {$$ = insere_lista_simbolo($1, novo_simbolo($4, yylineno, VARIAVEL, escopo_atual, $3));}
          | /*empty*/ {$$ = NULL;}
          ;

LISTA_ENUNCIADOS : ENUNCIADO
                 | LISTA_ENUNCIADOS ENUNCIADO
                 ;

ENUNCIADO: ID '=' EXPRESSAO_SIMPLES ';'
         | DECLARACAO 
         | RETURN EXPRESSAO_SIMPLES ';'
         | RETURN ';'
         | WHILE '(' EXPRESSAO_RELACIONAL ')' '{' {escopo_atual++;} LISTA_ENUNCIADOS '}' {
             imprime_tabela_simbolos(log_file, tab_simbolos); 
             tab_simbolos = remove_simbolos(tab_simbolos, escopo_atual);
             escopo_atual--;
         }
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
    log_file = fopen ("output.log", "w");
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

