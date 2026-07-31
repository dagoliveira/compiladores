# Representação Intermediária do LLVM (LLVM-IR)

A principal referência para o assembly do LLVM (LLVM-IR) é o [LangRef](https://llvm.org/docs/LangRef.html) do
próprio LLVM.

Uma outra forma que ajuda a entender como gerar LLVM-IR é utilizar o
compilador clang para emitir código em LLVM-IR. Para isso, utilize o
comando `clang -S -emit-llvm -O0 codigo.c` que vai gerar um arquivo
`codigo.ll`.

Caso a versão do clang em sua máquina seja antiga, instale uma versão
mais nova, como clang-19, para produzir um LLVM-IR atualizado.
Especialmente uma versão a partir da 15, pois a forma de usar ponteiros
foi atualizada.

# Identificadores

Identificadores são formados pelo seguinte padrão:

```
    [%@][-a-zA-Z$._][-a-zA-Z$._0-9]*
```

O primeiro caracter poder ser um '%' ou um '@'. O @ significa que o
identificador é global (variáveis globais, funções) em seu escopo,
enquanto o % implica que o identificador é local a determinada função.
Portanto, identificadores como \@xyz, ou @.minha-string são
identificadores globais, enquanto %xyz e %xyz.2 são locais.

## Variáveis globais

Variáveis globais, em LLVM-IR, são regiões alocadas em memória, e devem
ser inicializadas. Portanto, serão basicamente um ponteiro para uma
região de memória.

```
@x = global i32 2
```

O exemplo acima define uma variável global chamada \@x, do
tipo inteiro com 32 bits, e inicializa com o valor dois.

# Tipos

LLVM-IR é fortemente tipada, e o tipo inteiro pode possuir tamanho
arbitrário (quantidade de bits). O inteiro mais comum, com 32 bits, já
foi visto e é definido como `i32`. O formato para inteiros é
`i<quantidade de bits>`, portanto uma variável declarada como `i1` é um
inteiro de apenas um bit (usado em comparações, como se fosse um tipo
booleano).

Ponto flutuante é definido, primariamente, como `float` e `double`, e as
instruções para esse tipo de dado são diferentes das instruções que
operam sobre inteiros. 

Tipos agregados também são suportados (como arrays), mas não
vamos tratar disso aqui. Por fim, também existe o tipo `void`, que pode
ser usado para definir uma função que não retorna valor algum.

# Estrutura

Programas LLVM são compostos de módulos, onde cada módulo contém funções
e variáveis globais. Cada função será composta por variáveis locais e um ou mais blocos
básicos, e cada bloco básico contém instruções que são executadas em sequência.

```
+-----------------------+
|módulo                 |
|                       |
|    variáveis globais  |
|                       |
|    +--------------+   |
|    |função 1      |   |
|    |              |   |
|    |              |   |
|    +--------------+   |
|                       |
|    +--------------+   |
|    |função 2      |   |
|    |              |   |
|    +--------------+   |
|                       |
+-----------------------+
```

## Bloco Básico

Cada bloco básico inicia com um label, ou recebe de forma implícita um
label, contém um conjunto de instruções e finaliza com uma instrução
*terminadora*.

Um bloco básico tem uma entrada e uma saída (instrução terminadora),
portanto não tem instruções de desvio 'no meio' do bloco. As instruções
terminadores podem ser um desvio (*br*) ou retorno(*ret*), bem como
outros casos como a instrução *unreachable*.

O trecho de código abaixo possui três blocos básicos. O primeiro bloco básico
começa com o rótulo de entrada *Test* (que aponta para uma instrução `icmp`) e termina com uma instrução de
desvio *br*. Esse primeiro bloco contém duas instruções. O segundo trecho inicia com o rótulo *IfEqual* e termina
com um retorno. Por fim, o terceiro bloco básico inicia com o rótulo
*IfUnequal* e termina com um retorno. Os dois últimos blocos possuem apenas uma instrução.

O trecho de código implementa uma comparação de igualdade entre os
registradores %a e %b, caso sejam iguais, o bloco básico que inicia com
*IfEqual* será executado e o valor 1 retornado. Caso não sejam iguais, o
bloco que inicia com *IfUnequal* será executado e o valor zero
retornado.

```
Test:
  %cond = icmp eq i32 %a, %b
  br i1 %cond, label %IfEqual, label %IfUnequal
IfEqual:
  ret i32 1
IfUnequal:
  ret i32 0
```

# Funções

Funções são criadas com a palavra-chave *define*. Elas podem possuir um
tipo de retorno e parâmetros de entrada. Parâmetros de entrada podem ser
variáveis simples, ou ponteiros. Na verdade, muitos detalhes podem ser
alterados, como convenção de chamada e outros. Porém, a intenção deste
tutorial é ser bem simples.

O código abaixo demonstra uma função simples, chamada `@soma`, que
recebe dois parâmetros de entrada do tipo inteiro, e retorna a soma dos
dois. Como funções tem o escopo global, seu identificador deve começar
com @.

```
define i32 @soma(i32 %x, i32 %y) {
  %1 = add i32 %x, %y
  ret i32 %1
}
```

Para executar uma função usamos a instrução `call`. Existe, também, a
instrução `invoke` onde é possível tratar erros e trabalhar com
exceções, mas não iremos tratar disso. O código
abaixo tem um exemplo completo que utiliza a função soma
e também imprime um inteiro na tela. Nesse código, as variáveis %1 e %2
são inteiros inicializados, respectivamente, com os valores 1 e 2. A
função vai receber esses dois valores por cópia, e retornar a soma
deles. Por fim, esse resultado é impresso na tela com uma quebra de
linha no final.

```
declare i32 @printf(ptr noundef, ...)
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @soma(i32 %x, i32 %y) {
  %1 = add i32 %x, %y
  ret i32 %1
}

define i32 @main() {
    %1 = add i32 0, 1
    %2 = add i32 0, 2
    %3 = call i32 @soma(i32 %1, i32 %2)
    %4 = call i32 (ptr, ...) @printf(ptr noundef @write_int, i32 %3)
    ret i32 0
}
```

# Static Single Assignment (SSA)

LLVM-IR é uma linguagem do tipo Static Single Assignment (SSA). Isso
significa que todo registrador em uma função possui apenas uma única
atribuição (single Assignment), seu valor não é atualizado. Porém, visto
de forma estática, e atribuições dentro de um laço de repetição são
permitidas (daí vem a definição de Static). Veremos, posteriormente,
essas atribuições dinâmicas e a instrução *phi* ($\phi$). A linguagem
estar na forma SSA permite que muitas técnicas de otimização sejam
facilmente implementadas.

Em resumo, instruções que reescrevem no mesmo registrador devem ser
reescritas para utilizar um novo registrador. Por exemplo, o código
`x = 10; x = x + 1;` não é permitido em LLVM-IR pois a variável x possui
duas atribuições. O trecho de código poderia ser traduzido como
 abaixo, criando um novo registrador a cada atribuição.

```
$x.0 = add i32 0, 10
%x.1 = add i32 %x.0, 1
```

# Memória: alloca, store e load

Uma certa *facilidade* que LLVM-IR oferece é a gerência de memória de
forma automática, sem que o usuário se preocupe na forma que a pilha, ou
alguma estrutura de memória, seja organizada. Assim, a instrução
`alloca` vai retornar um ponteiro para uma região de memória que será
automaticamente desalocada ao final da função (ou escopo).

Em conjunto com essa instrução, vamos usar as instruções `store` e
`load` para armazenar e fazer a leitura dessa região de memória.

Como não vamos considerar tipos agregados, arrays e etc., um simples
store e load seria o suficiente. Porém, ao usar tipos agregados, onde
aritmética de ponteiros é importante para calcular a posição de um
elemento na memória, LLVM-IR oferece uma função que faz essa aritmética
(`getelementptr`), que não iremos cobrir neste texto.

O trecho de código a seguir demonstra como alocar um espaço na memória,
armazenar o valor 15 e fazer a leitura para uma nova variável. Depois,
esse valor da nova variável é incrementado e salvo novamente na posição
de memória. Note que para acesso a memória, podemos fazer quantos
`store` forem necessários para a mesma posição (ou ponteiro) uma vez que
SSA não se aplica ao acesso de memória.

```
store i32 15, ptr %x
%1 = load i32, ptr %x
%2 = add i32 %1, 1
store i32 %2, ptr %x
```

# Condicional e Desvio

Para executar condicionais podemos usar as instruções `icmp` para
inteiros, e `fcmp` para ponto-flutuante. A instrução `icmp` permite usar
as seguintes comparações:

```
eq: igual
ne: não é igual
ugt: maior que, sem sinal
uge: maior ou igual, sem sinal
ult: menor que, sem sinal
ule: menor ou igual, sem sinal
sgt: maior que, com sinal
sge: maior ou igual, com sinal
slt: menor que, com sinal
sle: menor ou igual, com sinal
```

A instrução `fcmp` é similar, mas em vez de considerar com e sem sinal
('u' e 's'), ela utiliza ordered e unordered ('o' e 'u') que tem
considerações diferentes em relação *Not a Number (NaN)*.

Essas instruções de comparação retornam um valor do tipo `i1`, ou seja,
verdadeiro (um) ou falso (zero).

Para executar um desvio, vamos utilizar esse resultado do tipo `i1` e a
instrução `br`. Essa instrução vai pular para um primeiro rótulo caso o
valor da variável do tipo `i1` seja verdadeiro, ou então vai pular para
o segundo rótulo caso contrário. 

O trecho de código abaixo, já visto ateriormente, implementa um `if` simples que verifica se dois valores (%a e %b) são
iguais, caso sejam iguais o valor 1 é retornado, caso contrário o valor
0 é retornado.

``` {#list:if label="list:if" basicstyle="\\small" caption="Exemplo de função"}
Test:
  %cond = icmp eq i32 %a, %b
  br i1 %cond, label %IfEqual, label %IfUnequal
IfEqual:
  ret i32 1
IfUnequal:
  ret i32 0
```

## Loop com instruções *phi*

Construir laços de repetição, de forma eficiente, geralment exige o uso da instrução-$\phi$. Essa pseudo-instrução "sabe" de onde veio o fluxo de controle, ou seja, sabe qual foi o bloco básico executado anteriormente. Dessa forma, podemos construir programas que respeitam a forma SSA. Afinal, a instrução-$\phi$ foi inventada especificamente para dar suporte ao SSA. 

Com essa informação do fluxo de controle, a instrução-$\phi$ retorna um valor diferente dependendo qual foi o bloco básico anterior. Por exemplo, considere o laço de repetição abaixo.


```
int main() {
    int i = 0;
    int sum = 0;
    while (i < 10) {
        sum += i;
        i++;
    }
    return sum;
}

```

Esse laço de repetição pode ser implementado pelo programa abaixo, usando a LLVM-IR e SSA. Não estamos usando memória, ou array, mas registradores que devem respeitar a forma SSA. Portanto, a variável `i` e `sum` possui três versões:
- A versão 0 (`%i.0` e `%sum.0`) recebe uma atribuição com o valor zero, anter de iniciar o laço. 
- A versão 1 (`%i.1` e `%sum.1`), usa a instrução-$\phi$ para receber o valor da versão 0 caso o bloco executado anteriormente tenha sido o `%entry`, ou o valor da versão 2 se o bloco executado anteriormente foi o `%while_body`. Essa versão 1 apenas consolida o valor de `i` e `sum`, de forma que quando a condicional for testada, os blocos seguintes podem usar o valor da versão 1 como o último valor correto. 
- Por fim, a versão 2 (`%i.2` e `%sum.2`) realiza as operações aritméticas do corpo do laço. 


```
define i32 @main() {
entry:
    %i.0 = add i32 0, 0
    %sum.0 = add i32 0, 0
    br label %while_cond

while_cond:
    %i.1 = phi i32 [ %i.0, %entry ], [ %i.2, %while_body ]
    %sum.1 = phi i32 [ %sum.0, %entry ], [ %sum.2, %while_body ]
    %cond = icmp slt i32 %i.1, 10
    br i1 %cond, label %while_body, label %while_exit

while_body:
    %sum.2 = add i32 %sum.1, %i.1
    %i.2 = add i32 %i.1, 1
    br label %while_cond

while_exit:
    ret i32 %sum.1
}
```
Notem que o programa é Static Single Assignment, e não Dynamic Single Assignment. As variáveis da versão 1 e 2 receberão diversas atribuições de forma dinâmica, ao longo da execução.

Notem também que o bloco `entry` possui uma instrução que pula para a linha seguinte: `br label %while_cond`. Por mais que isso possa parecer estúpido, as regras dessa representação exigem que os blocos básicos sejam criados de forma explícita, ou seja, que acabem com uma instrução terminadora (como um desvio ou retorno). Sem essa instrução, teríamos um "bloco básico" com dois pontos de entrada, ou seja, dois rótulos (`entry` e `while_cond`).

# Exemplo completo: Fatorial recursivo

No exemplo abaixo, o fatorial é computado de forma recursiva na
função `@fat`. Neste exemplo, iniciamos o programa com dois `declare` que avisa ao
módulo que usaremos duas funções externas, no caso a scanf e printf da
libc. Ainda criamos duas strings que são constantes, a primeira é a
string usada para o scanf que informa sobre a leitura de um inteiro
(\"%d\"); a segunda é similar, mas tem uma quebra de linha no final
(\"%d\\n\"), porém usar o valor hexadecimal para o carácter de quebra de
linha (0A).

A função scanf espera um ponteiro para cada valor que será lido, já a
função printf recebe valores por cópia para o que será impresso na tela.
As duas funções são chamadas pela instrução `call`. A função scanf vai
salvar, na posição de memória apontada pelo ponteiro %1, o valor lido do
teclado. Já a função printf vai imprimir na tela o valor salvo na
variável %4, que possui o retorno da função `@fat`.

```
declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @fat(i32 %x) {
    %1 = icmp sle i32 %x, 0
    br i1 %1, label %retFim, label %retRec
retFim:
    ret i32 1
retRec:
    %2 = sub i32 %x, 1
    %3 = call i32 @fat(i32 %2)
    %4 = mul i32 %x, %3
    ret i32 %4
}

define i32 @main() {
    %1 = alloca i32
    %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr @read_int, ptr %1)
    %3 = load i32, ptr %1
    %4 = call i32 @fat(i32 %3)
    %5 = call i32 (ptr, ...) @printf(ptr noundef @write_int, i32 %4)
    ret i32 0
}
```

# Exemplo completo: Fatorial iterativo

O código final modifica o exemplo anterior para usar um laço de repetição, o que o torna mais eficiente já que fatorial não é uma recursão de cauda (tail-call) para ser otimizado pelo compilador.

```
declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @fat(i32 %x) {
    %i.0 = add i32 1, 0
    %fat.0 = add i32 1, 0
    br label %while_header
while_header:
    %i.1 = phi i32 [%i.0, %0], [%i.2, %while_body]
    %fat.1 = phi i32 [%fat.0, %0], [%fat.2, %while_body]
    %1 = icmp sle i32 %i.1, %x
    br i1 %1, label %while_body, label %while_exit
while_body:
    %fat.2 = mul i32 %fat.1, %i.1
    %i.2 = add i32 %i.1, 1
    br label %while_header
while_exit:
  ret i32 %fat.1
}

define i32 @main() {
    %1 = alloca i32
    %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr @read_int, ptr %1)
    %3 = load i32, ptr %1
    %4 = call i32 @fat(i32 %3)
    %5 = call i32 (ptr, ...) @printf(ptr noundef @write_int, i32 %4)
    ret i32 0
}
```

Por fim, o primeiro bloco básico da função `@fat` não tem um rótulo explícito, portanto um valor numerado é atribuído ao bloco. O menor valor numerado disponível é o %0, por isso a instrução-$\phi$ usa os rótulos `%0` e `%while_body`. O código acima seria o equivalente ao abaixo.

```
declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @fat(i32 %x) {
0:
    %i.0 = add i32 1, 0
    %fat.0 = add i32 1, 0
    br label %while_header
while_header:
    %i.1 = phi i32 [%i.0, %0], [%i.2, %while_body]
    %fat.1 = phi i32 [%fat.0, %0], [%fat.2, %while_body]
    %1 = icmp sle i32 %i.1, %x
    br i1 %1, label %while_body, label %while_exit
while_body:
    %fat.2 = mul i32 %fat.1, %i.1
    %i.2 = add i32 %i.1, 1
    br label %while_header
while_exit:
  ret i32 %fat.1
}

define i32 @main() {
    %1 = alloca i32
    %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr @read_int, ptr %1)
    %3 = load i32, ptr %1
    %4 = call i32 @fat(i32 %3)
    %5 = call i32 (ptr, ...) @printf(ptr noundef @write_int, i32 %4)
    ret i32 0
}
```
