%{
#include <stdio.h>
int yylex();
int yyerror(char *s);
%}

%token NUMERO MAIS MENOS MUL DIV AP FP EOL

%left MAIS MENOS
%left MUL DIV

%%

CALC: /* empty */
 | CALC EXP EOL { printf("%d\n> ", $2); }
 | CALC EOL { printf("> "); } // linha em branco
 ;

EXP: FATOR
 | EXP MAIS FATOR { $$ = $1 + $3; }
 | EXP MENOS FATOR { $$ = $1 - $3; }
 ;

FATOR: TERMO
 | FATOR MUL TERMO { $$ = $1 * $3; }
 | FATOR DIV TERMO { $$ = $1 / $3; }
 ;

TERMO: NUMERO
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

