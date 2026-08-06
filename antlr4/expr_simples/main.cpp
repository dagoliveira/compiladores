#include <ANTLRInputStream.h>
#include <iostream>
#include <string>

#include "antlr4-runtime.h"
#include "LabeledExprLexer.h"
#include "LabeledExprParser.h"
#include "catchSyntaxErrors.h"

using namespace labeledexpr;
using namespace antlr4;

int main(int , const char **) {

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

        // Clear default console logging listeners
        lexer.removeErrorListeners();
        parser.removeErrorListeners();

        // Attach custom syntax error handler
        CatchSyntaxErrorListener el;
        lexer.addErrorListener(&el);
        parser.addErrorListener(&el);

        tree::ParseTree* tree = parser.prog();

        if (el.hasErrors()){
            std::cout << "Erros sintaticos/lexicos foram encontrados:\n";
            for (const auto& msg : el.getErrorMessages()) {
                std::cout << msg << "\n";
            }
        } else {
            std::cout << "Sentenca ok!\n";
            std::cout << "Arvore sintatica:\n" << tree->toStringTree(&parser) << std::endl;
        }
    }

    return 0;
}
