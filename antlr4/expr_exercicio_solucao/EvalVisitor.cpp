#include "LabeledExprParser.h"
#include <any>
#include "EvalVisitor.hpp"

using namespace labeledexpr;

EvalVisitor::EvalVisitor(){
    //Contrutor padrao
}

std::any EvalVisitor::visitPrintExpr(LabeledExprParser::PrintExprContext *ctx)  {
    // Executado com a seguinte producao:
    // stat:   expr NEWLINE                # printExpr
    int expr = std::any_cast<int>(visit(ctx->expr()));
    std::cout << expr << std::endl;
    return expr;
}

std::any EvalVisitor::visitAssign(LabeledExprParser::AssignContext *ctx)  {
    // Executado com a seguinte producao:
    // stat:   ID '=' expr NEWLINE         # assign
    std::string id = ctx->ID()->getText();
    int expr = std::any_cast<int>(visit(ctx->expr()));
    maping.erase(id);
    maping.emplace(id, expr);
    std::cout << id << " = " << expr << std::endl;
    return expr;
}

std::any EvalVisitor::visitParens(LabeledExprParser::ParensContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   '(' expr ')'                # parens
    return visit(ctx->expr());
}

std::any EvalVisitor::visitMulDiv(LabeledExprParser::MulDivContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   expr op=('*'|'/') expr      # MulDiv
    int left = std::any_cast<int>(visit(ctx->expr(0)));
    int right = std::any_cast<int>(visit(ctx->expr(1)));
    std::any res;
    if (ctx->op->getType() == LabeledExprParser::MUL)
        return left * right;
    return left / right;
}

std::any EvalVisitor::visitAddSub(LabeledExprParser::AddSubContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   expr op=('+'|'-') expr      # AddSub
    int left = std::any_cast<int>(visit(ctx->expr(0)));
    int right = std::any_cast<int>(visit(ctx->expr(1)));
    std::any res;
    if (ctx->op->getType() == LabeledExprParser::ADD)
        return  left + right ;
    return left - right;
}

std::any EvalVisitor::visitId(LabeledExprParser::IdContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   ID                          # id
    std::string id = ctx->ID()->getText();
    auto it = maping.find(id);
    if (it != maping.end())
        return it->second;
    std::cerr << "Tentando acessar um ID ('" << id << "') que nao foi definido anteriormente, usando o valor zero no lugar\n";
    return 0;
}

std::any EvalVisitor::visitInt(LabeledExprParser::IntContext *ctx)  {
    // Executado com a seguinte producao:
    // expr:   INT                         # int
    std::string s = ctx->INT()->getText();
    return std::stoi(s);
}
