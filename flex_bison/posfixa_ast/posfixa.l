%option yylineno 

%{
#include "posfixa.tab.h"
char err_buffer[500];
int yyerror(char *s);
%}

NUM [0-9]+

%%

{NUM} {yylval.valor = atof(yytext); return NUMERO;}
"+" {return MAIS;}
"-" {return MENOS;}
"*" {return MUL;}
"/" {return DIV;}
"(" {return AP;}
")" {return FP;}
\n { return EOL;}
[ \t] {/*ignorar espacos em branco, incluindo tabs*/}

. { sprintf(err_buffer, "caracter estranho '%c'", *yytext); yyerror(err_buffer); }

%%

// Sem codigo aqui, flex sera usado pelo bison e nao 'standalone'
