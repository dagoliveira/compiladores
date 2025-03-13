int yyerror(char *s);
/* Nodo da arvore sintatica abstrata (abstract syntatic tree - AST) */
struct AST {
  char tipo;
  int valor;
  struct AST *e;
  struct AST *d;
};


/* funcao para criar uma AST */
struct AST *newAST(char tipo, int valor, struct AST *e, struct AST *d);

/* funcao para avaliar, retornar o valor final, de uma AST */
int eval(struct AST * nodo);

/* delete and free an AST */
void freeAST(struct AST * nodo);


