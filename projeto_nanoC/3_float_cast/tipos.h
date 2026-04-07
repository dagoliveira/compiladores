#ifndef TIPOS_H
#define TIPOS_H

typedef enum Tipo_e {INTEIRO, REAL, VAZIO} Tipo;
typedef enum TipoSimbolo_e {VARIAVEL, FUNCAO} TipoSimbolo;


struct simbolo {
    char * lexema; // lexema eh a string/id que esta no codigo fonte (i.e., nome da variavel ou funcao)
    Tipo tipo; // No caso da funcao pode ser o tipo de retorno, o que inclui void (VAZIO); variavel tem apenas dois tipos: int e float (INTEIRO e REAL)
    TipoSimbolo tipo_simb; // Por enquanto, apenas dois tipos (variavel ou funcao)
    int escopo; // escopo 0 eh o principal (global), no LLVM tem o prefixo '@'; demais escopos tem o prefixo '%'
	int linha_declarado; // util para debug
    struct lista_args * args; // Se for uma funcao, precisamos saber quantos e quais os tipos dos argumentos para validar uma chamada a funcao
};

struct lista_args {
    Tipo tipo;
    struct lista_args * proximo;
};

struct lista_simbolo{
    struct simbolo * simb;
    struct lista_simbolo * proximo;
};

struct tabela_simbolos {
    struct simbolo * simb;
    struct tabela_simbolos * proximo;
};

// Registrador sao variaveis temporarias no LLVM, podem ter um nome/id ou apenas um numero que precisa ser crescente.
// Tambem tem um prefixo: '@' -> global, '%' -> local
typedef struct  {
	char nome[20];
	Tipo tipo; // INTEIRO, REAL ou VAZIO
} registrador;

struct lista_reg {
    registrador reg;
    struct lista_reg * proximo;
};
#endif
