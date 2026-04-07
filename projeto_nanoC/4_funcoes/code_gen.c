#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "code_gen.h"

// Registradores numericos precisam ser unicos e sempre incremental.
// Portanto, uma variavel contadora para controlar qual o ultimo reg.
int reg_atual = 0;

registrador novo_registrador(Tipo tipo){
	registrador reg;
	reg_atual++;
	sprintf(reg.nome, "%%%d",reg_atual);
	reg.tipo = tipo;
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
			if (simb->tipo == INTEIRO)
	            fprintf(fp, "@%s = global i32 0\n",simb->lexema);
			else if(simb->tipo == REAL)
				fprintf(fp, "@%s = global float 0.0\n",simb->lexema);
		} else {
			if (simb->tipo == INTEIRO)
                fprintf(fp, "\t%%%s = alloca i32\n",simb->lexema);
			else if(simb->tipo == REAL)
                fprintf(fp, "\t%%%s = alloca float\n",simb->lexema);
		}
		lista = lista->proximo;
	}
}

// Emitie a definicao da funcao, com ou sem argumentos
void emite_inicio_funcao(FILE *fp, struct simbolo *func, struct lista_simbolo *args){
	char tipo[30];
	switch (func->tipo){
		case INTEIRO: sprintf(tipo,"i32"); break;
		case REAL: sprintf(tipo,"float"); break;
		case VAZIO: sprintf(tipo,"void"); break;
	}
	fprintf(fp, "\ndefine %s @%s(", tipo, func->lexema);
	// Parametros sao registradores em LLVM, e portanto sujeitos a SSA
	// Portanto, vamos copiar os valores recebidos para 'variaveis' que estao na memoria (pilha)
	struct lista_simbolo *ls = args;
	while(ls != NULL){
		// Aqui a gente apenas declara os registradores que sao de fato os parametros, mas colocamos um nome com posfixo '_arg'
		if (ls->simb->tipo == INTEIRO)
			fprintf(fp, "i32 %%%s_arg",ls->simb->lexema);
		else if (ls->simb->tipo == REAL)
			fprintf(fp, "float %%%s_arg",ls->simb->lexema);
		if(ls->proximo != NULL)
			fprintf(fp, ", ");
		ls = ls->proximo;
	}
	fprintf(fp, ") {\nentry:\n");
	//Agora a gente copia o valor do registrador de parametro para uma variavel na pilha
	emite_variaveis(fp,args); // primeiro declara e aloca espaco na pilha
	ls = args;
	while(ls != NULL){
		if (ls->simb->tipo == INTEIRO)
			fprintf(fp, "\tstore i32 %%%s_arg, ptr %%%s\n",ls->simb->lexema,ls->simb->lexema);
		else if (ls->simb->tipo == REAL)
			fprintf(fp, "\tstore float %%%s_arg, ptr %%%s\n",ls->simb->lexema,ls->simb->lexema);
		ls = ls->proximo;
	}
}

// apenas fecha a funcao, ou seja, insere um '}'
void emite_fim_funcao(FILE *fp){
    fprintf(fp, "\n}\n");
}

registrador cast_integer_float(FILE *fp, registrador reg){
	registrador reg_cast = novo_registrador(REAL);
    fprintf(fp, "\t%s = sitofp i32 %s to float\n",reg_cast.nome,reg.nome);
    return reg_cast;
}

registrador cast_float_integer(FILE *fp, registrador reg){
	registrador reg_cast = novo_registrador(INTEIRO);
    fprintf(fp, "\t%s = fptosi float %s to i32\n",reg_cast.nome,reg.nome);
    return reg_cast;
}

// emite a operacao 'ret' com algum registrador
void emite_return(FILE *fp, registrador reg, struct simbolo * func){
	if (func->tipo == VAZIO)
		yyerror("tentando retornar algum valor em funcao VOID");

	if (func->tipo == INTEIRO){
		if (reg.tipo == REAL)
			reg = cast_float_integer(fp, reg);
		fprintf(fp, "\tret i32 %s\n",reg.nome);
	} else if (func->tipo == REAL){
		if (reg.tipo == INTEIRO)
			reg = cast_integer_float(fp, reg);
		fprintf(fp, "\tret float %s\n",reg.nome);
	}
}

// emite o ret void, caso alguma funcao void use o return explicito
void emite_return_void(FILE *fp, struct simbolo * func){
	if (func->tipo != VAZIO)
		yyerror("tentando retornar vazio (VOID) em funcao com valor de retorno");
	fprintf(fp, "\tret void\n");

}

// Salva o valor de um registrador em uma variavel que esta na memoria
void emite_atribuicao(FILE *fp, char *id, registrador reg, struct tabela_simbolos *ts){
	struct simbolo * simb = busca_simbolo(ts, id);
	if(simb == NULL || simb->tipo_simb != VARIAVEL)
		yyerror("variavel nao declarada");
	char prefixo = '@';
	if (simb->escopo > 0)
		prefixo = '%';
	if (simb->tipo == INTEIRO){
		if (reg.tipo == REAL)
			reg = cast_float_integer(fp, reg);
	    fprintf(fp, "\tstore i32 %s, ptr %c%s\n",reg.nome,prefixo,simb->lexema);
	} else if (simb->tipo == REAL){
		if (reg.tipo == INTEIRO)
			reg = cast_integer_float(fp, reg);
	    fprintf(fp, "\tstore float %s, ptr %c%s\n",reg.nome,prefixo,simb->lexema);
	}
}

// Carrega uma variavel (memoria) para um registrador
registrador simbolo_para_registrador(FILE *fp, struct simbolo *simb){
	if (simb == NULL)
		yyerror("tentando acessar simbolo nao declarado");
	if (simb->tipo_simb != VARIAVEL)
		yyerror("tentando acessar como variavel um simbolo que nao eh variavel");

	char prefixo = '@';
	if (simb->escopo > 0)
		prefixo = '%';

	registrador reg = novo_registrador(simb->tipo);
	if (simb->tipo == INTEIRO)
	    fprintf(fp, "\t%s = load i32, ptr %c%s\n",reg.nome, prefixo, simb->lexema);
	else if (simb->tipo == REAL){
	    fprintf(fp, "\t%s = load float, ptr %c%s\n",reg.nome, prefixo, simb->lexema);
	}
	return reg;
}

// Cria um registrador com o valor de um numero literal
registrador literal_para_registrador(FILE *fp, char *literal){
	int i = atoi(literal);
    float f = atof(literal);
	registrador reg = novo_registrador(INTEIRO);
	if (i == f) // INTEIRO
	    fprintf(fp, "\t%s = add i32 0, %d\n",reg.nome, i);
	else{
	    fprintf(fp, "\t%s = fadd float 0.0, %s\n",reg.nome, literal);
		reg.tipo = REAL;
	}
	return reg;
}

// Resolve uma expressao simples, e retorna em qual registrador esta o resultado
registrador emite_exp_simples_int(FILE *fp, registrador reg_l, char operacao, registrador reg_r){

	if (reg_l.tipo != reg_r.tipo){ // promover int para float
		if(reg_l.tipo == INTEIRO)
			reg_l = cast_integer_float(fp, reg_l);
		else
			reg_r = cast_integer_float(fp, reg_r);
	}
	char op[50];
	registrador reg = novo_registrador(reg_l.tipo);
	switch (operacao){
		case '+': 
			if(reg_l.tipo == INTEIRO) 
				sprintf(op, "add i32"); 
			else
				sprintf(op, "fadd float"); 
			break;
		case '-': 
			if(reg_l.tipo == INTEIRO) 
				sprintf(op, "sub i32"); 
			else
				sprintf(op, "fsub float"); 
			break;
		case '*': 
			if(reg_l.tipo == INTEIRO) 
				sprintf(op, "mul i32"); 
			else
				sprintf(op, "fmul float"); 
			break;
		case '/': 
			if(reg_l.tipo == INTEIRO) 
				sprintf(op, "sdiv i32"); 
			else
				sprintf(op, "fdiv float"); 
			break;
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

// Valida os argumentos da funcao. Se a quantidade bate, e se o tipo bate.
// Se o tipo nao bate, verifica se tem um void (erro) ou faz um cast apropriado.
void valida_args(FILE *fp, struct simbolo *func, struct lista_reg *args){
	struct lista_args *la = func->args;
	struct lista_reg *lr = args;
	while (la != NULL && lr != NULL){
		if (la->tipo != lr->reg.tipo){
			if (lr->reg.tipo == VAZIO)
				yyerror("nao pode passar um tipo void como parametro");
			if(la->tipo == INTEIRO)
				lr->reg = cast_float_integer(fp, lr->reg);
			else if(la->tipo == REAL)
				lr->reg = cast_integer_float(fp, lr->reg);
		}
		la = la->proximo;
		lr = lr->proximo;
	}
	if (la != NULL || lr != NULL)
		yyerror("quantidade de argumentos esperado pela funcao eh diferente da quantidade de argumentos passados");
}

// Emite a chamada de uma funcao, que pode ter ou não ter argumentos
registrador emite_chamada_funcao(FILE *fp, struct simbolo *func, struct lista_reg *args){
	if (func == NULL)
		yyerror("funcao nao declarada");
	if(func->tipo_simb != FUNCAO)
		yyerror("Tentando chamar como funcao um simbolo que nao eh funcao");
	valida_args(fp, func, args);
	registrador reg_resultado = novo_registrador(func->tipo);
	char tipo[30];
	switch (func->tipo){
		case INTEIRO: sprintf(tipo,"i32"); break;
		case REAL: sprintf(tipo,"float"); break;
		case VAZIO: sprintf(tipo,"void"); break;
	}
    fprintf(fp, "\t%s = call %s @%s(",reg_resultado.nome, tipo,func->lexema);
	while(args != NULL){
		if (args->reg.tipo == INTEIRO)
			fprintf(fp, "i32 %s",args->reg.nome);
		else if (args->reg.tipo == REAL)
			fprintf(fp, "float %s",args->reg.nome);
		if(args->proximo != NULL)
			fprintf(fp, ", ");
		args = args->proximo;
	}
    fprintf(fp, ")\n");
	return reg_resultado;
}
