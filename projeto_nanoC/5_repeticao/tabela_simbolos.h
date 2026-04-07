#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

#include "tipos.h"

// Retorna o primeiro simbolo que encontrar com aquele lexema, ou NULL caso
// nao encontre nenhum
struct simbolo * busca_simbolo(struct tabela_simbolos * ts, char *lexema);

struct simbolo * novo_simbolo(char *lexema, int linha_declarado, TipoSimbolo tipo_simb, int escopo, Tipo tipo);

struct lista_simbolo * insere_lista_simbolo(struct lista_simbolo * lista, struct simbolo * simb);
void atualiza_tipo_simbolos(struct lista_simbolo * lista, Tipo t);
void insere_func_args(struct simbolo * funcao, struct lista_simbolo * args);
void free_lista_simbolo(struct lista_simbolo * lista);

struct tabela_simbolos * insere_simbolo_ts(struct tabela_simbolos * ts, struct simbolo * simb);
struct tabela_simbolos * insere_simbolos_ts(struct tabela_simbolos * ts, struct lista_simbolo * lista);

struct tabela_simbolos * remove_simbolos(struct tabela_simbolos * ts, int escopo);

void imprime_tabela_simbolos(FILE * fp, struct tabela_simbolos * ts);
#endif
