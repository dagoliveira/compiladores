---
author: Daniel Oliveira
title: Blocos básicos, Gráficos de Fluxo e SSA
subtitle: Otimizações
institute: UFPR
date: Julho 2026
fontsize: 14pt
aspectratio: 169
header-includes:
    - \input{../babel.tex}
    - \usepackage{ragged2e}
---

# Livros

:::::::::::::: {.columns}
::: {.column width="50%"}
![](./img/cover_Compiladores_Principios_Tecnicas_e_Ferramentas_2_ed.png){ height=50% }

\footnotesize

Compiladores: Princípios, Técnicas e Ferramentas (2 ed.)

Caps. 8 e 9

:::
::: {.column width="50%"}
![](./img/cover_Modern_Compiler_Implementation_in_ML.png){ height=50% }

\footnotesize

Modern Compiler Implementation in [ML|Java|C]

Caps. 8, 10, 17, 18 e 19
:::
::::::::::::::

\footnotesize

Procure na Biblioteca (temos apenas o Dragão), Internet Archive ([https://archive.org/](https://archive.org/)) e Open Library ([https://openlibrary.org/](https://openlibrary.org/))

# Blocos Básicos

- Tipicamente um compilador vai analisar o código fonte por meio de um Gráfico de Fluxo de Controle (CFG) e Blocos Básicos (BB)
    - Alguns algoritmos e otimizações são mais eficiente sobre BB do que em enunciados individuais

\vfill

- Um bloco básico é uma sequência de enunciados (instruções) cujo controle de fluxo entra no início e o deixa no fim
    - Agrupamos instruções não interessantes (que não são desvios) do ponto de vista da análise de controle de fluxo

# Blocos Básicos

Algoritmo para particionar uma sequência de enunciados em BBs:

\vfill

\footnotesize

1. Determinar o conjunto de líderes (primeiros enunciados de um bloco básico)
    - O primeiro enunciado é um líder
    - Qualquer enunciado que seja objeto de um desvio condicional ou incondicional é um líder
    - Qualquer enunciado que siga diretamente um desvio condicional ou incondicional é um líder

\vfill

2. Para cada líder, seu bloco básico consiste no líder e em todos os enunciados até, mas não incluindo o próximo líder ou o final do programa.

# Blocos Básicos

- Quebre o seguinte programa em blocos básicos:

```
1. m <- 0                9.  x <- M[r]
2. v <- 0                10. s <- s + x
3. if v >= n goto 15     11. if s <= m goto 13
4. r <- v                12. m <- s
5. s <- 0                13. r <- r + 1
6. if r < n goto 9       14. goto 6
7. v <- v + 1            15. return m
8. goto 3
```

# Gráficos de Fluxo

- Uma vez que o programa foi particionado em BB, podemos representar o fluxo de controle por meio de um **grafo de fluxo**:
    - Cada nó é um BB
    - Existe uma aresta de B para C se: for possível executar o primeiro enunciado de C após o último de B

\vfill

- Caso exista uma aresta de B para C, dizemos que:
    - B é um **predecessor** de C
    - C é um **sucessor** de B

# Gráficos de Fluxo

Considere o seguinte exemplo:

\footnotesize

```
for i from 1 to 10 do
    for j from 1 to 10 do
        a[i, j] = 0.0;
for i from 1 to 10 do
    a[i,i] = 1.0;

1.  i = 1                  10. i = i + 1
2.  j = 1                  11. if i <= 10 goto (2)
3.  t1 = 10 * i            12. i = 1
4.  t2 = t1 + j            13. t5 = i - 1
5.  t3 = 8 * t2            14. t6 = 88 * t5
6.  t4 = t3 - 88           15. a[t6] = 1.0
7.  a[t4] = 0.0            16. i = i + 1
8.  j = j + 1              17. if i <= 10 goto (13)
9.  if j <= 10 goto (3)
```

# Gráficos de Fluxo

![Gráfico de fluxo](img/graf_fluxo_aho_fig_8_9.png){ height=80% }

# Gráficos de Fluxo

- Agora os BB podem ser reordenados e colocados em qualquer posição
    - Sem que isso altere o resultado do programa

\vfill

- Uma forma otimizada busca minimizar a quantidade de desvios
    - Por exemplo, colocando o alvo de uma comparação falsa de desvio logo em seguida (ou o destino de um jump, removendo o jump)

# Análise de Tempo de Vida (Variável Viva)

- Programas devem rodar, na máquina, com um número limitado de registradores
    - Ocorrendo, eventualmente, o spill (usando memória, que é mais lenta)

\vfill

- Variáveis (ou temporários) podem usar o mesmo registrador se nunca estão em uso ao mesmo tempo
    - Geralmente as linguagens intermediárias usam um número infinito de temporários (registradores)

# Análise de Tempo de Vida (Variável Viva)

Qual o tempo de vida das variáveis $a$, $b$ e $c$?

![CFG de um programa](./img/cfg_appel_10_1_completo.png){ height=65% }


# Análise de Tempo de Vida (Variável Viva)

:::::::::::::: {.columns}
::: {.column width="30%"}
![](./img/cfg_appel_10_1_apenas_cfg.png){ height=80% }
:::
::: {.column width="70%"}
\small

- $b$ está viva em $4$; não é definida em $3$, portanto está viva em $2 \rightarrow 3$; é definida em $2$
    - Seu tempo de vida é $\{2 \rightarrow 3, 3 \rightarrow 4\}$

\vfill

- $a$ está viva em $1 \rightarrow 2$ e $4 \rightarrow 5 \rightarrow 2$, mas não em $2 \rightarrow 3 \rightarrow 4$

\vfill

- $c$ tem duas possibilidades:
    1. Está viva desde a entrada, pode ser um parâmetro formal
    2. Encontramos uma variável não inicializada (podemos avisar ao usuário, ou não)
:::
::::::::::::::

# Análise de Tempo de Vida - Terminologia

:::::::::::::: {.columns}
::: {.column width="30%"}
![](./img/cfg_appel_10_1_apenas_cfg.png){ height=80% }
:::
::: {.column width="70%"}

\small

- Um grafo de fluxo tem arestas de entrada (dos predecessores) e saída (para os sucessores): out-edges e in-edges
    - out do nó 5: $5 \rightarrow 6$ e $5 \rightarrow 2$

\vfill

- O conjunto dos predecessores de um nó $n$ é $pred[n]$, e o conjunto dos sucessores é $succ[n]$
    - $pred[2] = \{1, 5\}$, $succ[5] = \{2, 6\}$

\vfill

- Uma atribuição **define** aquela variável; uma ocorrência ao lado direito de uma atribuição (ou em alguma expressão) **usa** aquela variável
    - $def[3] = \{c\}$, $use[3] = \{b, c\}$
:::
::::::::::::::

# Análise de Tempo de Vida - Terminologia

- Uma variável está viva entre sua definição e seus usos
    - Desde que não ocorra nenhuma outra definição no caminho

\vfill

- Definições ambíguas são um problema, que não vamos tratar!
    - Como por meio de um alias (ponteiros) ou funções com efeitos colaterais (side-effects, como alterar o estado global do programa)

# Análise de Tempo de Vida - Equações de Fluxo de Dados

- Podemos calcular o tempo de vida (liveness), usando use/def, da seguinte forma:
    1. Se a variável está em $use[n]$, então ela é live-**in** no nó $n$. Viva ao entrar no nó
    2. Se é live-in no nó $n$, então é live-**out** em todos os $pred[n]$
    3. Se é live-out em $n$ e não está em $def[n]$, então também é live-in em $n$

\vfill

- Esse cálculo é definido pelas seguintes equações de fluxo de dados:

![](./img/eq_10_3_liveness_appel.png){ height=20% }

# Análise de Tempo de Vida - Algoritmo

- O seguinte algoritmo resolve as equações por iteração

![](./img/liveness_algo_appel.png){ height=60% }


# Análise de Tempo de Vida - Algoritmo

- Tempo de vida é *naturalmente* um cálculo do uso até definição, em ordem reversa ao fluxo
    - Calculando primeiro o *out* e ordenando os nós "corretamente" a conversão do algoritmo é mais rápida

:::::::::::::: {.columns}
::: {.column width="30%"}
![](./img/cfg_appel_10_1_apenas_cfg.png){ height=60% }
:::
::: {.column width="70%"}
![](./img/liveness_calculo_appel.png){ height=60% }
:::
::::::::::::::


# Análise de Tempo de Vida

- Geralmente análises de fluxo são feitas em BB, sendo executadas de maneira bem mais rápida
    - As equações podem ser adaptadas para BB

\vfill

- Também podemos fazer a análise uma variável por vez, conforme a necessidade
    - Fazendo uma busca "reversa" no gráfico de fluxo a partir do uso até a definição

# Análise de Tempo de Vida - Estática e Dinâmica

- Uma análise dinâmica pode ser superior a estática
    - Podemos provar, para o grafo abaixo, que o nó 4 é inalcançável; a variável $a$ não será usada após o nó $2$

\vfill

![](./img/liveness_static_dynamic_appel.png){ height=60% }

# Análises de Fluxo de Dados

- Muitas otimizações seguem o mesmo padrão:
    - Análises de Fluxo de Dados: Percorre o gráfico de fluxo coletando informações
    - Transformação: Modifica o programa, com base nas informações coletadas, tornando-o mais rápido sem afetar sua saída

\vfill

- Uma análise comum é a de definições alcançantes (reaching definitions)

# Definições Alcançantes

- Verificar se uma atribuição (definição) de uma variável/temporário $t$ afeta o valor de $t$ em outro ponto no programa

\vfill

- Podemos falar que um enunciado "$d: t \leftarrow x \ binop \  y$" gera (**gen**) uma definição $d$
    - Bem como que ele mata (**kill**) qualquer definição de $t$, pois um "novo" $t$ foi definido

# Definições Alcançantes

- Usando **gen** e **kill**, podemos calcular o **in** e **out** com as equações de fluxo de dados abaixo
    - coletando a informação de quais definições chegam e saem de cada nó $n$

\vfill

![](./img/gen_kill_in_out_eq_appel.png){ height=30% }

# Definições Alcançantes - Exemplo

![](./img/gen_kill_def_exemplo.png){ height=50%}

\vfill

- No exemplo acima, descobrimos que apenas a definição $1$ de $a$ alcança o enunciado $3$
    - Podemos substituir (propagação de constantes) o enunciado $c > a$ por $c > 5$; é uma otimização?


# Expressões Alcançantes

- O mesmo tipo de análise (gen e kill) pode ser feito para expressões
    - Visando, por exemplo, eliminar subexpressões comuns

\vfill

- O enunciado $a * b + 5 * (2 + a * b)$ pode calcular, sem otimização, $a * b$ duas vezes

# Otimizações Comuns

- Propagação de constante (cópia)
    - Dado um enunciado $d$ do tipo "$d: t \leftarrow z$", onde $z$ é uma constante (ou variável/temporário)
    - Outro enunciado $n$ do tipo "$n: y \leftarrow t \ binop \ x$"
    - E a definição $d$ alcança $n$, podemos substituir $t$ em $n$ por $z$: $n: y \leftarrow z \ binop \ x$

\vfill

- Eventualmente, o enunciado $d$ poderia ser removido por otimizações que eliminam código morto (dead-code elimination)

# Otimizações Comuns

- Identidades algébricas, algumas vezes com redução de força (capacidade)
    - redução de força usa operações menos custosas para um determinado HW

\vfill

\footnotesize

```
x + 0 = 0 + x = x
x - 0 = x
x * 1 = 1 * x = x
x / 1 = x

x ** 2 = x * x
2.0 * x = x + x
x / 2 = x * 0.5
```

# Otimizações Comuns

- Nem todas as otimizações podem ser feitas, um compilador deve ser conservador e otimizações não podem alterar o resultado do programa
    - Suponha o seguinte enunciado que define $a$: $a \leftarrow b / c$
    - se $a$ não é usado após esse enunciado, podemos removê-lo?

\vfill
\pause

- Se removemos o enunciado e $c$ pode ter o valor zero, alteramos como o programa se comporta em determinado input
    - Pois não haverá mais a exceção de divisão por zero

# Otimizações

- Cap. 9 do livro do Dragão (Compiladores: Princípios, Técnicas e Ferramentas) apresenta várias otimizações usando um trecho do Quicksort como exemplo

\vfill

![](./img/cover_Compiladores_Principios_Tecnicas_e_Ferramentas_2_ed.png){ height=50% }

# Use-Def e Def-Use Chains

- Informações sobre definições alcançáveis podem ser armazenadas em:
    - Use-Def chains: para um uso de variável, informa quais definições podem alcançá-la
    - Def-Use chains: para uma definição de variável, informa quais usos que ela alcança

\vfill

- Essas estruturas permitem uma implementação eficiente dos algoritmos de otimização

# Use-Def e Def-Use Chains

- Embora essas definições podem ser complicadas de gerir (em termos de espaço e tempo):

\footnotesize

```
    if (cond1)
        x = 10; // essa definição alcança 3 usos
    else if (cond2)
        x = 20; // essa definição alcança 3 usos
    else
        x = 30; // essa definição alcança 3 usos

    if (cond3)
        y = x * z; // 3 definições alcançam esse uso
    else if (cond2)
        y = x + 5; // 3 definições alcançam esse uso
    else
        y = x - 1; // 3 definições alcançam esse uso
```

# Static Single-Assignment (SSA)

- SSA é uma melhora da ideia de def-use chain
    - Cada variável (temporário) tem apenas uma definição

\vfill

- Se essa definição ocorre dentro de um laço de repetição
    - Ela continua sendo única de forma estática
    - Embora podem acontecer várias de forma dinâmica

# Static Single-Assignment (SSA)

- Transformar um código SSA dentro de um BB é simples
    - Cada definição cria uma nova versão da variável

\vfill

![](./img/ssa_straight-line_appel.png){ height=50% }

# Static Single-Assignment (SSA)

- Mas o que fazer no CFG, entre BBs? 
    - Especialmente nos nós com mais de um predecessor, pontos de junção

\vfill


![](./img/ssa_cfg_before_phi_appel.png){ height=60% }

# Static Single-Assignment (SSA)

- Vamos criar uma ficção notacional, chamada função-$\phi$
    - Dessa forma, podemos ter: $a3 \leftarrow \phi(a1, a2)$

\vfill

- A função-$\phi$ "sabe" de onde vem o fluxo de controle
    - $a3$ recebe o valor de $a1$ caso o fluxo veio do primeiro predecessor
    - $a3$ recebe o valor de $a2$ caso o fluxo veio do segundo predecessor
    - E assim vai, a função-$\phi$ pode ter vários argumentos (função variádica, como printf)

# Static Single-Assignment (SSA)

- Assim, primeiro adicionamos as funções-$\phi$
    - Depois renomeamos as variáveis
\vfill

![](./img/ssa_cfg_before_phi_appel.png){ height=60% }
![](./img/ssa_cfg_phi_renaming_appel.png){ height=60% }

# Static Single-Assignment (SSA)

- O(s) algoritmo(s) para inserir a função-$\phi$ estão no cap. 19 do livro do Tigre (Appel)
    - Não vamos tratar deles aqui

\vfill

- Mas como implementamos (removemos) a função-$\phi$? \pause
    - Uma forma é usar a operação $move$ no final de cada bloco predecessor da função-$\phi$
    - Essa remoção da função-$\phi$ é a única coisa que precisamos para converter de SSA para algo que pode ser traduzido para linguagem de máquina

# Static Single-Assignment (SSA)

- Otimizações se tornam eficientes e simples quando o código está na forma SSA
    - Eliminação de código morto
    - Propagação de cópia/constante
    - Redução de constantes (constant folding)
    - Condições constantes
    - Eliminação de código inalcançável

# Static Single-Assignment (SSA)

- Eliminação de código morto

\vfill

![](./img/ssa-dead-code-appel.png){ height=40% }

# Static Single-Assignment (SSA)

- Redução de constantes (constant folding):
    - Se $x \leftarrow a \ binop \ b$, onde $a$ e $b$ são constantes
    - Avaliar $c \leftarrow a \ binop \ b$ em tempo de compilação, e substituir $x$ para $x \leftarrow c$

\vfill

- Depois repetimos a otimização de propagação de constantes/cópia

# Static Single-Assignment (SSA)

- Condições constantes:
    - Se temos um desvio condicional **if** $a<b$ **goto** $L_1$ **else** $L_2$
    - onde $a$ e $b$ são constantes, podemos substituir por um salto incondicional, **goto** $L_1$ ou **goto** $L_2$

\vfill

- $L_1$ ou $L_2$ pode se tornar inalcançável
    - Então eliminamos todos os enunciados de $L_1$ ou $L_2$

# Laços

- Laços, onde a maior parte da execução acontece, não será tratado aqui
    - Existem otimizações como mover código invariante, e tratar variáveis de indução

\vfill

- Cap 9 do Dragão (Aho), e cap 18 do Tigre (Appel) tratam de loops

