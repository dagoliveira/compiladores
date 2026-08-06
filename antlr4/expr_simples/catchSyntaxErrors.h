#include "antlr4-runtime.h"
#include <iostream>
#include <vector>
#include <string>

class CatchSyntaxErrorListener : public antlr4::BaseErrorListener {
private:
    std::vector<std::string> errorMessages;

public:
    void syntaxError(antlr4::Recognizer *recognizer, 
                     antlr4::Token *offendingSymbol, 
                     size_t line, 
                     size_t charPositionInLine, 
                     const std::string &msg, 
                     std::exception_ptr e) override {

        std::string error = "Line " + std::to_string(line) + ":" + 
                            std::to_string(charPositionInLine) + " - " + msg;
        errorMessages.push_back(error);
    }

    bool hasErrors() const {
        return !errorMessages.empty();
    }

    const std::vector<std::string>& getErrorMessages() const {
        return errorMessages;
    }
};
