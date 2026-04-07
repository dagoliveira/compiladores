# Projeto NanoC

Neste projeto será implementado um compilador simples. Vamos usar uma gramática similar ao C, mas bem limitada.

Não vamos gerar código para nenhuma arquitetura alvo, mas vamos usar a representação intermediária do LLVM (LLVM-IR). Essa representação intermediária poderá ser compilada, ou interpretada, para qualquer arquitetura alvo que está no backend do LLVM. Portanto, para implementar/entender o presente projeto, primeiro deve conhecer a LLVM-IR.

## Arquivos Base

Os arquivos base para iniciar o projeto estão na pasta [0_base](./0_base/).

## Etapa 1 - Tabela de símbolos

Nesta etapa, deverá ser implementado apenas uma tabela de símbolos. Use os arquivos base, e onde tiver ações sintáticas relacionadas a um símbolo (como declarações de variáveis, ou de funções) você deve inserir o símbolo numa tabela de símbolos.

A tabela de símbolos pode ser uma lista ligada normal, ou para melhor desempenho uma HASH. Ela deve conter pelo menos as informações de escopo, tipo (INT, FLOAT ou VOID), lexema (string com o nome da variável ou função) e qual o tipo de símbolo (variável, função, parâmetros formais, ...)

O que deve ser feito:
- Controlar o escopo, onde o escopo global pode ser 0, e a cada novo escopo uma variável é incrementada. Ao sair do escopo a variável é decrementada.
- Cada variável declarada é inserida na tabela de símbolo
- Cada função declarada será inserida na tabela de símbolo, o escopo de funções será sempre o zero pois não temos funções aninhadas
- Ao sair de um escopo, as variáveis desse escopo podem/devem ser removidas da tabela.

Como extra você já pode verificar, nos momentos em que um símbolo é usado, se o mesmo está na tabela de símbolos (já foi declarado) ou não. Caso não esteja na tabela, isso é um erro semântico e seu compilador deve informar o usuário (e a compilação deve falhar).

Como testar: Imprima a tabela de símbolos em certos momentos, como ao sair do escopo (antes de remover qualquer símbolo), e antes de finalizar o parser do programa.

Um exemplo de solução simples está em [1_tabela_simbolos](./1_tabela_simbolos/).

## Etapa 2 - Expressões simples usando apenas INT (ignorando argumentos em funções)

Nesta etapa, as expressões aritméticas devem ser implementadas (EXPRESSAO_SIMPLES). Não precisa implementar suporte a FLOAT, apenas INT. 

A passagem de parâmetros (chamada de função) também não deve ser implementada. Embora as expressões encontradas em uma chamada de funções serão, naturalmente, implementadas. Por exemplo, a chamada de função `func( a + 2, 2 / 5)` possui duas expressões `a + 2` e `2 / 5` que serão traduzidas para LLVM.

Dificuldades:
	- Como gerenciar as variáveis visto que LLVM é SSA, uma sugestão é deixar as variáveis em memória (alloca que usa a pilha). Sempre que acessar uma variável deve ser usado o load, e ao escrever será usado um store.
	- Como e quando emitir as variáveis, tanto globais como locais.
	- Definir, ou não, uma estrutura nova para gerenciar as expressões. Precisa gerenciar os tipos diferentes como registrador temporário, símbolo (variável) e literal (número).

O que deve ser implementado:
	- ID e NUM de FATOR
	- Tudo de EXPRESSAO_SIMPLES
	- Atribuição, DECLARACAO e RETURN do ENUNCIADO
	- Inicio e Fim de funções

O que não precisa preocupar ainda:
	- Funções sendo chamadas no meio da expressão
    - EXPRESSAO_RELACIONAL

Como testar: Abra o arquivo LLVM gerado e verifique o código. Teste expressões variadas inserindo-as num código simples, apenas com main.

Um exemplo de solução simples está em [2_expressoes_simples](./2_expressoes_simples/).

## Etapa 3 - Acrescentando float e cast implícito

Agora devemos considerar o tipo FLOAT, e não apenas o INT. Portanto, devemos fazer cast implícito. Na gramática usada, não há cast explícito.

O que considerar:
	- return deve verificar o tipo de retorno da função atual
	- LLVM não opera usando tipos mistos, sempre precisa transformar os operando para terem o mesmo tipo

Um exemplo de solução simples está em [3_float_cast](./3_float_cast/).

## Etapa 4 - Chamadas de funções (com e sem argumentos)

Finalmente vamos implementar as chamadas de funções. Como já implementamos uma boa parte do nanoC, o corpo da função já está praticamente implementado.

O que considerar:
    - definir/declarar a função com os argumentos, que serão registradores temporários; Considerando a restrição SSA, podemos copiar os registradores temporários para variáveis em memoria (stack), como na Etapa 2.
    - na chamada, devemos validar os parâmetros (quantidade e tipo)
    - Cuidado para parâmetro void, e.g. caso o usuário chame uma função VOID nos argumentos de outra função.

Um exemplo de solução simples está em [4_funcoes](./4_funcoes/).

## Etapa 5 - Repetição

Não temos if-else, mas precisamos implementar o WHILE. Outros tipos de repetição, ou seleção, não serão muito diferentes ou difíceis de implementar após entender o WHILE.

O que considerar:
    - Resolver as expressões relacionais
    - Ajustar os labels, talvez uma pilha para controlar os labels (uma vez que temos escopos aninhados)
    - Fazer os teste com o resultado de uma expressão relacional, pulando para os labels corretos

Um exemplo de solução simples está em [5_repeticao](./5_repeticao/).

