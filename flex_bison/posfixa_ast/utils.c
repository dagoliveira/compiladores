#include <stdio.h>
#include <stdlib.h>
#include "utils.h"

/* funcao para criar uma AST */
struct AST *newAST(char tipo, int valor, struct AST *e, struct AST *d){
  struct AST *nodo = malloc(sizeof(struct AST));
  
  if(!nodo) {
    yyerror("Sem espaco!");
    exit(0);
  }
  nodo->tipo = tipo;
  nodo->e = e;
  nodo->d = d;
  nodo->valor = valor;
  return nodo;

}

/* funcao para avaliar, retornar o valor final, de uma AST */
void print_postorder(struct AST *nodo){
    if (nodo->tipo == 'N'){
        printf("%d ",nodo->valor);
        return;
    }
    print_postorder(nodo->e);
    print_postorder(nodo->d);
    printf("%c ",nodo->tipo);
}

/* delete and free an AST */
void freeAST(struct AST *nodo){
    if(nodo->e != NULL)
        freeAST(nodo->e);
    if(nodo->d != NULL)
        freeAST(nodo->d);
    free(nodo);
}

