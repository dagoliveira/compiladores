#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela_simbolos.h"
#include "compilador.h"


struct simbolo * novo_simbolo(char *lexema, int linha_declarado, TipoSimbolo tipo_simb, int escopo, Tipo tipo){
    struct simbolo * novo = malloc(sizeof(struct simbolo));
    novo->lexema = lexema;
	novo->linha_declarado = linha_declarado;
    novo->tipo_simb = tipo_simb;
    novo->escopo = escopo;
    novo->tipo = tipo;
	novo->args = NULL;
    return novo;
}

struct lista_simbolo * insere_lista_simbolo(struct lista_simbolo * lista, struct simbolo * simb){
    // insere no final
    struct lista_simbolo *aux, *novo = malloc(sizeof(struct lista_simbolo));
    novo->simb = simb;
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

void atualiza_tipo_simbolos(struct lista_simbolo * lista, Tipo t){
    while(lista != NULL){
        lista->simb->tipo = t;
        lista = lista->proximo;
    }
}

void free_lista_simbolo(struct lista_simbolo * lista){
    if(lista == NULL)
        return;
    free_lista_simbolo(lista->proximo);
    free(lista);
}
struct tabela_simbolos * insere_simbolo_ts(struct tabela_simbolos * ts, struct simbolo * simb){
    struct simbolo *simb_busca = busca_simbolo(ts, simb->lexema);
    if(simb_busca != NULL && simb_busca->escopo == simb->escopo){
        char erro[500];
        sprintf(erro, "simbolo '%s' ja declarado antes", simb->lexema);
        yyerror(erro);
    }
    struct tabela_simbolos * novo = malloc(sizeof(struct tabela_simbolos));
    novo->simb = simb;
    novo->proximo = ts;
    return novo;
}
struct tabela_simbolos * insere_simbolos_ts(struct tabela_simbolos * ts, struct lista_simbolo * lista){
    struct lista_simbolo * aux = lista;
    while(aux != NULL){
        ts = insere_simbolo_ts(ts, aux->simb);
        aux = aux->proximo;
    }
    return ts;
}

struct simbolo * busca_simbolo(struct tabela_simbolos * ts, char *lexema){
    while(ts != NULL){
        if(strcmp(ts->simb->lexema, lexema) == 0)
            return ts->simb;
        ts = ts->proximo;
    }
    return NULL;
}

struct tabela_simbolos * remove_simbolos(struct tabela_simbolos * ts, int escopo){
    struct tabela_simbolos * aux;
    while(ts != NULL && ts->simb->escopo == escopo){
        free(ts->simb);
        aux = ts;
        ts = ts->proximo;
        free(aux);
    }
    return ts;
}

void insere_func_args(struct simbolo * funcao, struct lista_simbolo * args){
    struct lista_args * novo, * ultimo;
    while(args != NULL){
        novo = malloc(sizeof(struct lista_args));
        novo->tipo = args->simb->tipo;
        novo->proximo = NULL;
        if(funcao->args == NULL)
            funcao->args = novo;
        else
            ultimo->proximo = novo;
        ultimo = novo;
        args = args->proximo;
    }
}

void imprime_tipo(FILE *fp, Tipo tipo){
    switch (tipo) {
        case INTEIRO: fprintf(fp, "int"); break;
        case REAL: fprintf(fp, "float"); break;
        case VAZIO: fprintf(fp, "void"); break;
        case RELACIONAL: fprintf(fp, "relacional"); break;
    }
}
void imprime_funcao(FILE *fp, struct simbolo *func){
	int escopo = func->escopo;
	while(escopo >=0){
		fprintf(fp, "**");
		escopo--;
	}
    fprintf(fp," lexema=%s; FUNCAO; linha_declarado=%d; escopo=%d; tipo=",func->lexema,func->linha_declarado,func->escopo);
    imprime_tipo(fp, func->tipo);
    fprintf(fp, "; args:{");
    struct lista_args *args = func->args;
    while(args != NULL){
        imprime_tipo(fp, args->tipo);
        if(args->proximo != NULL){
            fprintf(fp, ", ");
        }
        args = args->proximo;
    }
    fprintf(fp, "}\n");
}
void imprime_variavel(FILE *fp, struct simbolo *var){
	int escopo = var->escopo;
	while(escopo >=0){
		fprintf(fp, "**");
		escopo--;
	}
    fprintf(fp," lexema=%s; VARIAVEL; linha_declarado=%d; escopo=%d; tipo=",var->lexema,var->linha_declarado,var->escopo);
    imprime_tipo(fp, var->tipo);
    fprintf(fp, "\n");
}
void imprime_tabela_simbolos(FILE *fp, struct tabela_simbolos * ts){
    fprintf(fp, "--------------Tabela-Simbolos--------------\n");
    while(ts != NULL){
        if(ts->simb->tipo_simb == FUNCAO)
            imprime_funcao(fp, ts->simb);
        else
            imprime_variavel(fp, ts->simb);
        ts = ts->proximo;
    }
    fprintf(fp, "--------------FIM-Tabela-Simbolos----------\n");
}

