%{
#include<stdio.h>
%}

letra [a-zA-Z]

%%

"+" { printf("caracter '+'\n");}
"=" { printf("caracter '='\n");}
"+=" { printf("string '+='\n");}
"while" { printf("string 'while'\n");}
[a-zA-Z][a-zA-Z1-9]* { printf("identificador: %s\n",yytext);}
. { printf("outra coisa '%s'\n", yytext);}

%%

int main(int argc, char **argv) {
    yylex();
    return 0;
}
