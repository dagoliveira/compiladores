%{
#include <stdio.h>
#include <stdlib.h>
#include "tabela_simbolos.h"
#include "compilador.h"

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


%token INT FLOAT VOID RETURN
%token <lexema>NUM <lexema>ID 

%type <lista_s>LISTA_IDS <lista_s>LISTA_ARGS
%type <tipo>TIPO

%left '+' '-'
%left '*' '/'

%%

PROGRAMA: LISTA_DECLARACOES
        DECLARACORES_FUNCOES {
        imprime_tabela_simbolos(log_file, tab_simbolos);
        }
        ;

LISTA_DECLARACOES: LISTA_DECLARACOES DECLARACAO
                 | /*empty*/
                 ;

DECLARACAO: TIPO LISTA_IDS ';' {atualiza_tipo_simbolos($2,$1); tab_simbolos = insere_simbolos_ts(tab_simbolos, $2); imprime_tabela_simbolos(log_file, tab_simbolos);}
           ;

TIPO: INT {$$ = INTEIRO;}
    | FLOAT {$$ = REAL;}
    | VOID {$$ = VAZIO;}
    ;

LISTA_IDS: ID {$$ = insere_lista_simbolo(NULL, novo_simbolo3($1, VARIAVEL, escopo_atual));}
            | LISTA_IDS ',' ID {$$ = insere_lista_simbolo($1, novo_simbolo3($3, VARIAVEL, escopo_atual));}
            ;

DECLARACORES_FUNCOES: DECLARACORES_FUNCOES DECLARACAO_FUNCAO
                           | DECLARACAO_FUNCAO
                           ;

DECLARACAO_FUNCAO: TIPO ID { struct simbolo *func = novo_simbolo4($2, FUNCAO, escopo_atual, $1);tab_simbolos = insere_simbolo_ts(tab_simbolos, func); escopo_atual++;} '(' LISTA_ARGS ')' {
                 struct simbolo *func = busca_simbolo(tab_simbolos, $2);
                 insere_func_args(func, $5);
                 tab_simbolos = insere_simbolos_ts(tab_simbolos, $5);
                 fprintf(log_file, "Iniciando funcao %s\n",$2);
                 } 
                 '{' LISTA_ENUNCIADOS '}' {imprime_tabela_simbolos(log_file, tab_simbolos); 
                 tab_simbolos = remove_simbolos(tab_simbolos, escopo_atual); 
                 escopo_atual--;
                 fprintf(log_file, "Finalizando funcao %s\n",$2);
                 }
                 ;

LISTA_ARGS: TIPO ID {$$ = insere_lista_simbolo(NULL, novo_simbolo4($2, VARIAVEL, escopo_atual, $1));}
          | LISTA_ARGS ',' TIPO ID {$$ = insere_lista_simbolo($1, novo_simbolo4($4, VARIAVEL, escopo_atual, $3));}
          | /*empty*/ {$$ = NULL;}
          ;

LISTA_ENUNCIADOS : ENUNCIADO
                 | LISTA_ENUNCIADOS ENUNCIADO
                 ;

ENUNCIADO: ID '=' EXPRESSAO ';'
         | DECLARACAO 
         | RETURN EXPRESSAO ';'
                  
EXPRESSAO: EXPRESSAO '+' EXPRESSAO
         | EXPRESSAO '-' EXPRESSAO
         | EXPRESSAO '*' EXPRESSAO
         | EXPRESSAO '/' EXPRESSAO
         | FATOR
         ;
FATOR: ID
     | NUM
     | '(' EXPRESSAO ')'
     ;

%%

int main(int argc, char ** argv) {
    log_file = fopen ("compilador.log", "w");
    //out_file = fopen ("output.ll", "w");
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
        yylineno=1;
        yyparse();
    } else if (argc == 1) {
        yyparse();
    }    
    fprintf(log_file, "Finalizando compilacao\n");
    //fclose(out_file);
    fclose(log_file);
    return 0;
}

int yyerror(const char *s) {
  fprintf(stderr, "Erro na linha %d: %s\n", yylineno,s);
  exit(1);
  //return 0;
}

