#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "code_gen.h"

// Registradores numericos precisam ser unicos e sempre incremental.
// Portanto, uma variavel contadora para controlar qual o ultimo reg.
int reg_atual = 0;

registrador novo_registrador(){
	registrador reg;
	reg_atual++;
	sprintf(reg.nome, "%%%d",reg_atual);
	return reg;
}

// Emite a declaracao de variaveis, tanto globais como locais.
// Variaveis sempre estarao na pilha, na memoria.
void emite_variaveis(FILE *fp, struct lista_simbolo *ls){
    fprintf(log_file, "(code_gen) emitindo variaveis\n");
	struct lista_simbolo *lista = ls;
	struct simbolo * simb;
	while( lista != NULL){
		simb = lista->simb;
		if (simb->tipo_simb != VARIAVEL)
			yyerror("iniciando um simbolo que deveria ser variavel");
		if(simb->escopo == 0){
	            fprintf(fp, "@%s = global i32 0\n",simb->lexema);
		} else {
                fprintf(fp, "\t%%%s = alloca i32\n",simb->lexema);
		}
		lista = lista->proximo;
	}
}

// sem args ainda
void emite_inicio_funcao(FILE *fp, struct simbolo *func){
    fprintf(fp, "\ndefine i32 @%s() {\nentry:\n", func->lexema);
}

// apenas fecha a funcao, ou seja, insere um '}'
void emite_fim_funcao(FILE *fp){
    fprintf(fp, "\n}\n");
}

// emite a operacao 'ret' com algum registrador
void emite_return(FILE *fp, registrador reg){
    fprintf(fp, "\tret i32 %s\n",reg.nome);
}

// Salva o valor de um registrador em uma variavel que esta na memoria
void emite_atribuicao(FILE *fp, char *id, registrador reg, struct tabela_simbolos *ts){
	struct simbolo * simb = busca_simbolo(ts, id);
	if(simb == NULL)
		yyerror("variavel nao declarada");
	char prefixo = '@';
	if (simb->escopo > 0)
		prefixo = '%';
    fprintf(fp, "\tstore i32 %s, ptr %c%s\n",reg.nome,prefixo,simb->lexema);
}

// Carrega uma variavel (memoria) para um registrador
registrador simbolo_para_registrador(FILE *fp, struct simbolo *simb){
	if (simb == NULL)
		yyerror("tentando acessar simbolo nao declarado");
	if (simb->tipo_simb != VARIAVEL)
		yyerror("tentando acessar como variavel um simbolo que nao eh variavel");

	registrador reg = novo_registrador();
	reg.tipo = simb->tipo;
	char prefixo = '@';
	if (simb->escopo > 0)
		prefixo = '%';
    fprintf(fp, "\t%s = load i32, ptr %c%s\n",reg.nome, prefixo, simb->lexema);
	return reg;
}

// Cria um registrador com o valor de um numero literal
registrador literal_para_registrador(FILE *fp, char *literal){
	registrador reg = novo_registrador();
	reg.tipo = INTEIRO;
    fprintf(fp, "\t%s = add i32 0, %d\n",reg.nome, atoi(literal));
	return reg;
}

// Resolve uma expressao simples, e retorna em qual registrador esta o resultado
registrador emite_exp_simples_int(FILE *fp, registrador reg_l, char operacao, registrador reg_r){

	char op[50];
	registrador reg = novo_registrador();
	reg.tipo = reg_l.tipo;
	switch (operacao){
		case '+': sprintf(op, "add i32"); break;
		case '-': sprintf(op, "sub i32"); break;
		case '*': sprintf(op, "mul i32"); break;
		case '/': sprintf(op, "sdiv i32"); break;
		default: yyerror("operacao nao suportada");
	}
    fprintf(fp, "\t%s = %s %s, %s\n",reg.nome, op, reg_l.nome, reg_r.nome);
	return reg;
}


struct lista_reg * insere_lista_reg(struct lista_reg * lista, registrador reg){
    // insere no final
    struct lista_reg *aux, *novo = malloc(sizeof(struct lista_reg));
    novo->reg = reg;
    novo->proximo = NULL;
    if(lista == NULL){
        return novo;
    }
    aux = lista;
    while(aux->proximo != NULL)
        aux = aux->proximo;
    aux->proximo = novo;
    return lista;
}

void free_lista_reg(struct lista_reg * lista){
    if(lista == NULL)
        return;
    free_lista_reg(lista->proximo);
    free(lista);
}
