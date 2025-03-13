%{
int caracteres = 0;
int palavras = 0;
int linhas = 0;
%}

letra [a-zA-Z]

%%

{letra}+ { palavras++; caracteres += strlen(yytext); }
\n { caracteres++; linhas++; }
. { caracteres++; }

%%

int main(int argc, char **argv) {
    yylex();
    printf("linhas: %d\npalavras: %d\ncaracteres: %d\n", linhas, palavras, caracteres);
    return 0;
}
