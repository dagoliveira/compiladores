# Exercício de fixação

Altere os arquivos da [calculadora com árvore sintática abstrata](./calculadora_ast) para permitir o uso de variáveis.

## Dicas

- Faça uma tabela de símbolos que pode ser simples, como uma lista ligada. A tabela armazena um nó que mantem o valor atual da variável.
- A tabela de símbolos deve permitir a inserção de um novo símbolo (nome de variável), e a verificação se um símbolo existe.
- A regra de EXP deve permitir a atribuição, algo como "NOME = EXP".
- A regra de TERMO deve incluir uma nova derivação que permite a leitura de uma variável (similar a leitura de um númnero).
