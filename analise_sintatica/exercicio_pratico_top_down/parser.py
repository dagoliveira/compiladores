# Este compilador implementa a seguinte gramatica, onde 'vazio' seria a cadeia vazia:
# S ::= E $ | $
# E ::= T E_linha
# E_linha ::= + T E_linha | 'vazio'
# T ::= F T_linha
# T_linha ::= * F T_linha | 'vazio'
# F ::= ( E ) | ID | NUM

import sys, re

entrada = []

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
    if re.match("\*",lexema):
        return "MULTIPLICA"
    if re.match("\(",lexema):
        return "ABRE_PARENTESES"
    if re.match("\)",lexema):
        return "FECHA_PARENTESES"
    if re.match("[a-zA-Z][a-zA-Z_0-9]*",lexema):
        return "ID"
    return None

# Verifica se o lookahead token eh o token esperado, removendo ele da entrada (consumindo)
# Caso nao seja o esperado, acusa um erro
def match(esperado):
    token = lookahead()
    if token == esperado:
        if token != "EOL":
            entrada.pop(0)
    else:
        erro("esperava '"+esperado+"', mas foi encontrado um '"+str(token)+"'")

def S():
    token = lookahead()
    if token == "EOL":
        print("linha vazia")
    else:
        E()
        match("EOL")

def E():
    T()
    E_linha()

def T():
    F()
    T_linha()

def E_linha():
    if lookahead() == "MAIS":
        match("MAIS")
        T()
        E_linha()
    else:
        return # vazio

def T_linha():
    if lookahead() == "MULTIPLICA":
        match("MULTIPLICA")
        F()
        T_linha()
    else:
        return # vazio

def F():
    token = lookahead()
    if token == "ABRE_PARENTESES":
        match("ABRE_PARENTESES")
        E()
        match("FECHA_PARENTESES")
    elif token == "ID":
        match("ID")
    elif token == "NUM":
        match("NUM")
    else:
        erro("esperava um '(', 'ID' ou 'NUM', mas foi encontrado '"+token+"'")

def parse():
    S() # simbolo nao-terminal inicial

def main() -> int:
    sentenca = input("entre com uma sentenca: ")
    global entrada
    entrada = sentenca.split()
    parse()
    print("Sentenca aceita, tudo ok!")
    return 0

if __name__ == '__main__':
    sys.exit(main())
