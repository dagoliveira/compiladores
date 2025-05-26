# Este compilador implementa a seguinte gramatica, onde 'vazio' seria a cadeia vazia:
# S ::= E $ | A $ | $
# E ::= T E_linha
# E_linha ::= + T E_linha | - T E_linha | 'vazio'
# T ::= F T_linha
# T_linha ::= * F T_linha | / F T_linha | 'vazio'
# F ::= ( E ) | ID | NUM
# A ::= let ID = E

import sys, re

entrada = []
tabela_simbolos = {}

# Informa o erro ao usuario e termina o programa
def erro(msg):
    print("ERRO: "+msg)
    print("entrada ainda nao avaliada: ",entrada)
    sys.exit(-1)

# Verifica qual o proximo token na entrada, o lookahead token
def lookahead():
    if len(entrada) == 0:
        return "EOL"
    lexema = entrada[0]
    if re.match("[0-9]+",lexema):
        return "NUM"
    if re.match("\+",lexema):
        return "MAIS"
    if re.match("-",lexema):
        return "MENOS"
    if re.match("\*",lexema):
        return "MULTIPLICA"
    if re.match("\/",lexema):
        return "DIVIDE"
    if re.match("\(",lexema):
        return "ABRE_PARENTESES"
    if re.match("\)",lexema):
        return "FECHA_PARENTESES"
    if re.match("let",lexema):
        return "LET"
    if re.match("=",lexema):
        return "ATRIBUICAO"
    if re.match("[a-zA-Z][a-zA-Z_0-9]*",lexema):
        return "ID"
    return None

# Verifica se o lookahead token eh o token esperado, removendo ele da entrada (consumindo)
# Caso nao seja o esperado, acusa um erro
def match(esperado):
    token = lookahead()
    if token == esperado:
        if token != "EOL":
            return entrada.pop(0)
        return None
    else:
        erro("esperava '"+esperado+"', mas foi encontrado um '"+str(token)+"'")

def S():
    token = lookahead()
    if token == "EOL":
        print("Linha vazia!")
    elif token == "LET":
        A()
        match("EOL")
    else:
        lexval = E()
        match("EOL")
        print("> ",lexval)

def E():
    lexval = T()
    lexval = E_linha(lexval)
    return lexval

def T():
    lexval = F()
    lexval = T_linha(lexval)
    return lexval

def E_linha(valor):
    token = lookahead()
    if token == "MAIS":
        match("MAIS")
        lexval = T()
        lexval = lexval + valor
        lexval = E_linha(lexval)
        return lexval
    elif token == "MENOS":
        match("MENOS")
        lexval = T()
        lexval = lexval - valor
        lexval = E_linha(lexval)
        return lexval
    else:
        return valor # vazio

def T_linha(valor):
    token = lookahead()
    if token == "MULTIPLICA":
        match("MULTIPLICA")
        lexval = F()
        lexval = valor * lexval
        lexval = T_linha(lexval)
        return lexval
    if token == "DIVIDE":
        match("DIVIDE")
        lexval = F()
        lexval = valor / lexval
        lexval = T_linha(lexval)
        return lexval
    else:
        return valor # vazio

def F():
    token = lookahead()
    if token == "ABRE_PARENTESES":
        match("ABRE_PARENTESES")
        lexval = E()
        match("FECHA_PARENTESES")
        return lexval
    elif token == "ID":
        var = match("ID")
        if var in tabela_simbolos:
            return tabela_simbolos[var]
        else:
            erro("simbolo nao encontrado: '"+str(var)+"'")
    elif token == "NUM":
        return int( match("NUM") )
    else:
        erro("esperava um '(', 'ID' ou 'NUM', mas foi encontrado '"+str(token)+"'")

def A():
    match("LET")
    var = match("ID")
    match("ATRIBUICAO")
    lexval = E()
    global tabela_simbolos
    tabela_simbolos[var] = lexval


def parse():
    S() # simbolo nao-terminal inicial

def main() -> int:
    while True:
        sentenca = input("entre com uma sentenca ('exit' para sair): ")
        if sentenca == "exit":
            break
        global entrada
        entrada = sentenca.split()
        parse()
    return 0

if __name__ == '__main__':
    sys.exit(main())
