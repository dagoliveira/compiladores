# Exemplos de código

## Contador de palavras (Apenas Flex)

O [primeiro exemplo](./wordcount) implementa algo similar a ferramenta *wc* do linux. O programa faz a leitura de texto da entrada padrão até que o fim de arquivo seja entrado (CTRL + d), e imprime a contagem de caracteres, palavras e linhas.

## Calculadora (Flex + Bison)

Dois exemplos integram Flex e Bison ao implementar uma calculadora simples. 

O [primeiro exemplo de calculadora](./calculadora) é o mais simples, usando o valor dos símbolos a direita da regra e sintetizando um novo valor conforme as regras são reduzidas. Dessa forma, ao reduzir, por exemplo, a regra para soma, dois valores são somados e armazenados (ou sintetizados) no "nó pai".

O [segundo exemplo de calculadora](./calculadora_ast) é um pouco mais sofisticado, pois ele gera uma árvore sintática, que será avaliada no símbolo inicial da gramática, computando assim o valor final da expressão.

## Notação Pós fixa

O [exemplo final](./posfixa_ast) modifica o exemplo da calculadora com árvore sintática para transformar a expressão da notação infixa para pós fixa. O algoritmo apenas percorre, e imprime os nós, da árvore de forma pós fixa.
