#include "LabeledExprParser.h"
#include <any>
#include "EvalVisitor.hpp"

using namespace labeledexpr;

EvalVisitor::EvalVisitor(){
    // Construtor padrão
}

std::any EvalVisitor::visitPrintExpr(LabeledExprParser::PrintExprContext *ctx)  {
    // Executado com a seguinte producao:
    // stat:   expr NEWLINE                # printExpr
    // Um exemplo de implementacao pode visitar os nós filhos,
    // que no caso tem apenas 'expr' como filho: visit( ctx->expr() ).
    // Depois usamos o valor retornado ao avaliar o nó filho, fazendo o 
    // cast para o tipo correto std::any_cast<TIPO_CORRETO>( VALOR_RETORNADO )
    int expr = std::any_cast<int>(visit(ctx->expr()));
    // Agora podemos imprimir na tela, para informar o usuario do resultado
    std::cout << expr << std::endl;
    // Podemos retornar qualquer coisa para o nó 'prog', que sera descartado
    return expr; // ou return 0;
}

std::any EvalVisitor::visitAssign(LabeledExprParser::AssignContext *ctx)  {
    // Executado com a seguinte producao:
    // stat:   ID '=' expr NEWLINE         # assign
    return 0;
}

std::any EvalVisitor::visitParens(LabeledExprParser::ParensContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   '(' expr ')'                # parens
    return 0;
}

std::any EvalVisitor::visitMulDiv(LabeledExprParser::MulDivContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   expr op=('*'|'/') expr      # MulDiv
    // Para saber qual operacao devemos fazer, precisamos
    // verificar qual é o 'op'. Como '*' e '/' tem uma definição
    // no arquivo LabelExpr.g4 (MUL :   '*'), podemos usar isso:
    // if (ctx->op->getType() == LabeledExprParser::MUL) -> multiplicação
    // if (ctx->op->getType() == LabeledExprParser::DIV) -> divisão
    //
    // Essa produção tem dois filhos 'expr', podemos visitar cada um deles da seguinte forma:
    // visit(ctx->expr(0)) -> filho da esquerda, o primeiro a aparecer na gramatica
    // visit(ctx->expr(1)) -> filho da direita, o segundo a aparecer na gramatica
    return 0;
}

std::any EvalVisitor::visitAddSub(LabeledExprParser::AddSubContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   expr op=('+'|'-') expr      # AddSub
    return 0;
}

std::any EvalVisitor::visitId(LabeledExprParser::IdContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   ID                          # id
    // Para recuperar o lexema, qual seria o texto/caracteres do ID:
    // ctx->ID()->getText()
    return 0;
}

std::any EvalVisitor::visitInt(LabeledExprParser::IntContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   INT                         # int
    // INT também tem um lexema associado, que pode ser acessado assim:
    // ctx->INT()->getText()
    // a função std:stoi() pode ser usada para converter uma string em int
    // Portanto, uma forma de implementar a seguinte função seria:
    std::string s = ctx->INT()->getText();
    return std::stoi(s);
}
