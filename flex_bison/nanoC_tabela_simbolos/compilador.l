%option yylineno 

%{
#include "tabela_simbolos.h"
#include "compilador.h"
#include "compilador.tab.h"
%}

id [a-zA-Z][a-zA-Z1-9]*

digitos [0-9]+

fracao_opcional (.{digitos})?

expoente_opcional ([Ee][+-]?{digitos})?
%%



"int" { return INT;}

"float" { return FLOAT;}

"void" { return VOID;}

"return" { return RETURN;}

"+" |
"-" |
"*" |
"/" |
";" |
"," |
"(" |
")" |
"{" |
"}" |
"=" { return yytext[0];}



{digitos}{fracao_opcional}{expoente_opcional} {
    yylval.lexema = strdup(yytext);
    return NUM;
}

{id} {
    yylval.lexema = strdup(yytext);
    return ID;
}

\n {
    //return EOL;
}

[ \t] {/*ignorar espacos em branco, incluindo tabs*/}

%%

// Sem codigo aqui, flex sera usado pelo bison e nao 'standalone'
