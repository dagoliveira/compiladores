%{
#include <stdio.h>
#include "utils.h"
int yylex();
int yyerror(char *s);
%}

%union {
  struct AST *nodo;
  int valor;
}


%token <valor> NUMERO 
%token MAIS MENOS MUL DIV AP FP EOL

%type <nodo> EXP FATOR TERMO

%left MAIS MENOS
%left MUL DIV

%%

CALC: /*empty*/
 | CALC EXP EOL { 
    printf("%d\n", eval($2) ); 
    freeAST($2);
    printf("> ");
 }
 | CALC EOL { printf("> "); } // linha em branco
 ;

EXP: FATOR
 | EXP MAIS EXP { $$ = newAST('+', 0, $1, $3); }
 | EXP MENOS FATOR { $$ = newAST('-', 0, $1, $3); }
 ;

FATOR: TERMO
 | FATOR MUL TERMO { $$ = newAST('*', 0, $1, $3); }
 | FATOR DIV TERMO { $$ = newAST('/', 0, $1, $3); }
 ;

TERMO: NUMERO { $$ = newAST('N', $1, NULL, NULL); }
 | AP EXP FP { $$ = $2; }
 ;


%%

int main(int argc, char ** argv) {
  printf("> ");
  yyparse();
  return 0;
}

int yyerror(char *s) {
  fprintf(stderr, "Erro: %s\n", s);
  return 0;
}

