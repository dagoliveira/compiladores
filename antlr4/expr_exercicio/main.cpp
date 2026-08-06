#include <ANTLRInputStream.h>
#include <iostream>
#include <string>

#include "antlr4-runtime.h"
#include "LabeledExprLexer.h"
#include "LabeledExprParser.h"
#include "EvalVisitor.hpp"
#include "catchSyntaxErrors.h"

using namespace labeledexpr;
using namespace antlr4;

int main(int , const char **) {
    EvalVisitor ev;

    std::string s;


    while(true){
        std::cout << "Entre com um input ('q' para sair): ";
        std::getline(std::cin, s);
        if (s == "q")
            break;

        ANTLRInputStream input(s + "\n");
        LabeledExprLexer lexer(&input);
        CommonTokenStream tokens(&lexer);

        tokens.fill();

        LabeledExprParser parser(&tokens);

        // Remove o 'console logging listeners' padrão
        lexer.removeErrorListeners();
        parser.removeErrorListeners();

        // Coloca o nosso listener de erros para que possamos reportar os erros
        CatchSyntaxErrorListener el;
        lexer.addErrorListener(&el);
        parser.addErrorListener(&el);

        // Iniciamos o parser com a regra 'prog', que eh a regra inicial
        tree::ParseTree* tree = parser.prog();

        if (el.hasErrors()){
            std::cout << "Erros sintaticos/lexicos foram encontrados:\n";
            for (const auto& msg : el.getErrorMessages()) {
                std::cout << msg << "\n";
            }
        } else {
            std::cout << "Eval: ";
            ev.visit(tree);
        }
    }

    return 0;
}
