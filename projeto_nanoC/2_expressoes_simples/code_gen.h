#ifndef CODE_GEN_H
#define CODE_GEN_H

#include "compilador.h"
#include "tipos.h"
#include "tabela_simbolos.h"



struct lista_reg * insere_lista_reg(struct lista_reg * lista, registrador reg);
void free_lista_reg(struct lista_reg * lista);

// Emite a declaracao de variaveis, tanto globais como locais.
// Variaveis sempre estarao na pilha, na memoria.
void emite_variaveis(FILE *fp, struct lista_simbolo *ls);

// sem args ainda, apenas um inicio generico
void emite_inicio_funcao(FILE *fp, struct simbolo *func);
// apenas fecha a funcao, ou seja, insere um '}'
void emite_fim_funcao(FILE *fp);
// emite a operacao 'ret' com algum registrador
void emite_return(FILE *fp, registrador reg);

// Salva o valor de um registrador em uma variavel que esta na memoria
void emite_atribuicao(FILE *fp, char *id, registrador reg, struct tabela_simbolos *ts);

// Carrega uma variavel (memoria) para um registrador
registrador simbolo_para_registrador(FILE *fp, struct simbolo *simb);
// Cria um registrador com o valor de um numero literal
registrador literal_para_registrador(FILE *fp, char *literal);

// Resolve uma expressao simples, e retorna em qual registrador esta o resultado
registrador emite_exp_simples_int(FILE *fp, registrador reg_l, char operacao, registrador reg_r);
#endif
