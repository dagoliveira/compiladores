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

// Emitie a definicao da funcao, com ou sem argumentos
void emite_inicio_funcao(FILE *fp, struct simbolo *func, struct lista_simbolo *args);
// apenas fecha a funcao, ou seja, insere um '}'
void emite_fim_funcao(FILE *fp);
// emite a operacao 'ret' com algum registrador
void emite_return(FILE *fp, registrador reg, struct simbolo * func);
// emite o ret void, caso alguma funcao void use o return explicito
void emite_return_void(FILE *fp, struct simbolo * func);

// Salva o valor de um registrador em uma variavel que esta na memoria
void emite_atribuicao(FILE *fp, char *id, registrador reg, struct tabela_simbolos *ts);

// Carrega uma variavel (memoria) para um registrador
registrador simbolo_para_registrador(FILE *fp, struct simbolo *simb);
// Cria um registrador com o valor de um numero literal
registrador literal_para_registrador(FILE *fp, char *literal);

// Resolve uma expressao simples, e retorna em qual registrador esta o resultado
registrador emite_exp_simples_int(FILE *fp, registrador reg_l, char operacao, registrador reg_r);

// Emite a chamada de uma funcao, que pode ter ou não ter argumentos
registrador emite_chamada_funcao(FILE *fp, struct simbolo *func, struct lista_reg *args);

// Emite uma comparacao entre dois registradores (resultados de uma expressao simples)
registrador emite_expressao_relacional(FILE *fp, registrador reg_l, OpRelacional operacao, registrador reg_r);

// Emite o inicio de um while, antes da expressao relacional (pois loop do while volta para antes do teste
void emite_inicio_while(FILE *fp);

// Emite o salto, apos o teste do while, que vai para o corpo do while ou para o final do while
void emite_fim_teste_while(FILE *fp, registrador reg);
//
// Emite o fim do while, que salta para o inicio do while (teste) e também insere o label de final do while
void emite_fim_while(FILE *fp);
#endif
