# Top-down parser

O [parser.py](./parser.py) (analisador sintático), escrito em Python, implementa uma gramática de expressões bem simples:

```
S: E EOL 
 | EOL
 ;

E: T E_linha
 ;

E_linha: + T E_linha 
       | /*empty*/
       ;

T: F T_linha
 ;

T_linha: * F T_linha
       | /*empty*/
       ;

F: ( E )
 | ID
 | NUM
 ;
```

Os símbolos terminais (tokens) são quatro: **(**, **)**, **ID** e **NUM**; Contudo, foi acrescentado o **EOL** como fim de linha, no lugar do fim de arquivo, representando o final da entrada.

NUM pode ser apenas dígitos inteiros e sem sinal, a expressão regular é a seguinte: `[0-9]+`

ID, que representa um identificador (como o nome de uma variável), deve iniciar com uma letra seguida por uma ou mais letras, dígitos e underline. A expressão regular é a seguinte: `[a-zA-Z][a-zA-Z_0-9]*`

O parser analisa apenas uma linha de entrada, informando se é uma sentença válida ou não (erro sintático). Depois, ele encerra o programa.

## Analisador léxico

Como a parte do analisador léxico, implementado ao fazer um `split` na entrada e expressões regulares na função `lookahead`, é extremamente simples. Cada token deve ter um espaço entre o outro. 

Logo, expressões como `5*(2+3)` não são válidas. O analisador léxico exige que a expressão seja entrada da seguinte forma: `5 * ( 2 + 3 )`

## Exercício

Modifique o parser como segue:

### Outras operações

Acrescente, modificando a gramática, outras operações como subtração (`-`) e divisão (`/`). Porém, não inclua recursão a esquerda pois impedirá (caso não haja restrição na profundidade da árvore gramatical gerada) que o parser funcione.

### Atribuição de variáveis

Modifique a gramática mais uma vez para que seja permitido atribuição de uma expressão a uma variável, que posteriormente poderá ser usada em uma expressão (`ID`). Manter uma tabela de símbolos em Python é simples ao usar o tipo dicionário [`dict`](https://docs.python.org/3/tutorial/datastructures.html#dictionaries).

#### Dica

Não inclua na gramática um comando com a seguinte sintaxe: `ID = E`. Tente descobrir o porquê não seria possível.

Uma sugestão de sintaxe é iniciar a atribuição com uma palavra-chave, como `let` ou `var`: `let ID = E`.

### Implemente a calculadora

Modifique o parser para que o resultado da expressão seja calculado e impresso na tela, após analisar a linha entrada. Uma sugestão é alterar a main para que o parser seja chamado várias vezes, sendo possível entrar com várias linhas durante a execução do programa.

Uma possível forma de implementar essa calculadora seria por meio da construção da árvore, que deve ser avaliada. Algo semelhante ao que foi feito em [Flex/Bison](../flex_bison/calculadora_ast). Porém, é possível resolver sem a construção de uma árvore sintática, mas pensando na notação pós-fixa.

### Solução

Uma possível solução está implementada [aqui](./solucao/parser.py). Tente resolver o exercício antes de olhar uma solução pronta!!!
