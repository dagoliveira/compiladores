O [parser](./parser.py) (analisador sintático), escrito em Python, implementa uma gramática de expressões bem simples:

```
S: E EOL
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

Os símbolos terminais (tokens) são quatros: **(**, **)**, **ID** e **NUM**; Contúdo, foi acrescentado o **EOL** como fim de linha, no lugar do fim de arquivo, representado o final da entrada.

NUM pode ser apenas dígitos inteiros e sem sinal, a expressão regular é a seguinte: `[0-9]+`

ID, que representa um identificador (como o nome de uma variável), deve iniciar com uma letra seguida por uma ou mais letras, dígitos e underline. A espressão regular é a seguinte: `[a-zA-Z][a-zA-Z_0-9]*`

O parser analisa apenas uma linha de entrada, informando se é uma sentença válida ou não (erro sintático). Depois, ele encerra o programa.
