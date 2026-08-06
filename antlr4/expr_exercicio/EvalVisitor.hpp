#pragma once

#include "LabeledExprBaseVisitor.h"
#include "LabeledExprParser.h"

#include <any>

using namespace labeledexpr;

class EvalVisitor : public labeledexpr::LabeledExprBaseVisitor {
public:
    EvalVisitor();
    ~EvalVisitor() override = default;

    std::any visitPrintExpr(LabeledExprParser::PrintExprContext *ctx) override;
    std::any visitAssign(LabeledExprParser::AssignContext *ctx) override;
    std::any visitParens(LabeledExprParser::ParensContext *ctx) override;
    std::any visitMulDiv(LabeledExprParser::MulDivContext *ctx) override;
    std::any visitAddSub(LabeledExprParser::AddSubContext *ctx) override;
    std::any visitId(LabeledExprParser::IdContext *ctx) override;
    std::any visitInt(LabeledExprParser::IntContext *ctx) override;
};

