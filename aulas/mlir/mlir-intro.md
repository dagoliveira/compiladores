# Multi-Level Intermediate Representation (MLIR)

MLIR é uma infraestrutura de compiladores flexível e extensível, criada dentro do projeto LLVM. Porém, diferente da LLVM IR, que tem apenas uma abstração de baixo nível, MLIR foi desenvolvida para ser multi-nível. Ou seja, ela não tem apenas valores, instruções básicas e desvio de fluxo simples.
Dessa forma, ela pode trabalhar em níveis de abstração específicos para um domínio, como Inteligência Artificial e Machine Learning, ou com arquiteturas atípicas e heterogêneas, incluindo CPU, GPU, TPU, FPGA e ASICs. Com essa "unificação", podemos reutilizar melhor código e otimizações de um domínio.

O pipeline normal de um compilador seria algo como:

```
Linguagem Fonte  →  AST  →  LLVM IR  →  Código de máquina
```

Quando chegamos no LLVM IR, o compilador perdeu informações, como onde estão os laços de repetição, que seriam úteis para otimização. Portanto, a grande ideia do MLIR é traduzir apenas partes da IR que já podem ter seu nível de abstração reduzido para mais próximo da arquitetura alvo. Assim, em certos momentos, um código pode ter vários níveis (multi-nível) de abstração ao mesmo tempo. MLIR permite criar o que chama de *dialetos*, ou usar algum dialeto existente. Esses dialetos representam e otimizam operações em diferentes níveis de abstração. Por exemplo, o dialeto `scf` (structured control flow) oferece operações como `for`, `if`, `while`. O dialeto `scf` pode ser otimizado e então reduzido (*lowering*) para `cf` (control flow). Por sua vez, o dialeto `cf` oferece operações como branch (*br*).

O pipeline típico de um compilador usando a infraestrutura do MLIR seria algo como:


```
Dialetos de alto nível (Tensor/Linalg)
        ↓ lowering pass
Dialetos de nível médio (e.g. memref/scf)
        ↓ lowering pass
Dialetos de baixo nível (e.g. arith/cf/memref)
        ↓ lowering pass
Dialeto LLVM
        ↓ translation
LLVM IR  →  código de máquina
```

Uma visão geral com os principais conceitos de MLIR estão disponíveis na referência da linguagem: [LangRef](https://mlir.llvm.org/docs/LangRef/).

# Conceitos

MLIR, assim como LLVM IR, também usa valores na forma SSA. Os prefixos `%` e `@` também permanecem. Em LLVM IR, temos apenas os rótulos para o início dos blocos básicos, que usavam o prefixo local `%`. Porém, agora temos o prefixo `^` para blocos básicos no MLIR.

## Dialetos

Por meio de **dialetos** nós podemos estender e interagir com o ecossistema do MLIR. Podemos definir novas **operações**, **atributos** e **tipos**. Dessa forma, é possível criar representações intermediárias especializadas para diferentes domínios de aplicação ou estágios de compilação. Cada dialeto possui um **namespace** exclusivo, que será utilizado como prefixo para identificar todas as operações, atributos e tipos que ele define.

Diversos dialetos podem coexistir em um único módulo MLIR, por isso o nome **Multi-Level**. MLIR utiliza **passes** que podem ser usados tanto para uma análise ou otimização, como para transformar um dialeto em outro.

Alguns dos principais dialetos são:

- Builtin
- Arith
- SCF/CF
- Memref
- Func
- LLVM

## Módulos

MLIR tem um contêiner de nível mais alto (**top-level**) que agrupa todas as operações locais. Seria o que em LLVM chamamos de unidade de tradução.

```
module {
    ...
}
```

## Operações

No MLIR, tudo é uma *operação* (frequentemente abreviada como "op"). Não existe um conjunto de instruções fixo como no LLVM IR; em vez disso, os dialetos *definem* suas próprias operações.

Uma operação possui:

- Um **nome**, escrito no formato `dialeto.nome_da_op` (ex.: `arith.addi`, `memref.load`).
- Zero ou mais **operandos** (valores SSA de entrada).
- Zero ou mais **resultados** (valores SSA de saída). Sim, uma operação pode ter mais de um resultado.
- Zero ou mais **atributos** (dados nomeados e constantes em tempo de compilação associados à operação).
- Zero ou mais **regiões** (blocos de código aninhados — é assim que o MLIR representa fluxos de controle estruturados, como loops e corpos de funções).
- Uma **assinatura de tipo** para cada operando e resultado.

Exemplo:

```mlir
%result = arith.addi %a, %b : i32
```

Aqui, `arith` é o nome do dialeto, `addi` é o nome da operação, `%a` e `%b` são os operandos, `%result` é o resultado (único) e `i32` é o tipo do resultado.

## Blocos

A principal diferença entre LLVM e MLIR, em relação a blocos, é que agora os blocos recebem argumentos de entrada, com uma notação similar a de funções. Portanto, agora não precisamos mais das intruções-$\phi$. 

O exemplo, disponível no site do MLIR, está abaixo. Nesse exemplo, uma função chamada `simple` possui os blocos `bb0`, `bb1`, `bb2`, `bb3` e `bb4`. O primeiro bloco, `bb0`, recebe como argumentos os valores que a função recebe. Os blocos `bb1` e `bb2` são dominados por `bb0` (em termos simples, o fluxo de controle sempre passa por `bb0` até chegar no bloco que ele domina), portanto as variáveis definidas em `bb0` estão disponíveis em `bb1` e `bb2`, bem como em todos os blocos que ele domina. Como `bb3` não é dominado por `bb1` nem por `bb2`, esses blocos passam um argumento para `bb3` ao desviar para ele. Por fim, `bb3` passa dois argumentos para `bb4`, sendo o primeiro o valor que recebe do bloco anterior (`bb1` ou `bb2`) e o valor que vem de `bb0` (`%a`).

```func.func @simple(i64, i1) -> i64 {
^bb0(%a: i64, %cond: i1): // Code dominated by ^bb0 may refer to %a
  cf.cond_br %cond, ^bb1, ^bb2

^bb1:
  cf.br ^bb3(%a: i64)    // Branch passes %a as the argument

^bb2:
  %b = arith.addi %a, %a : i64
  cf.br ^bb3(%b: i64)    // Branch passes %b as the argument

// ^bb3 receives an argument, named %c, from predecessors
// and passes it on to bb4 along with %a. %a is referenced
// directly from its defining operation and is not passed through
// an argument of ^bb3.
^bb3(%c: i64):
  cf.br ^bb4(%c, %a : i64, i64)

^bb4(%d : i64, %e : i64):
  %0 = arith.addi %d, %e : i64
  return %0 : i64   // Return is also a terminator.
}
```

# Instalação

Talvez seja possível instalar os pacotes pré-compilados do MLIR na sua distribuição. Busque por mlir no seu gerenciador de pacotes, algo como `mlir`, `mlir-devel` e `mlir-static`; ou `mlir-tools` e  `libmlir-22-dev`.

## Compilando a partir do fonte

Caso contrário, será necessário compilar o LLVM junto com o MLIR. Separe um tempo razoável para essa tarefa.

```
git clone https://github.com/llvm/llvm-project.git
mkdir llvm-project/build
cd llvm-project/build
cmake -G Ninja ../llvm \
   -DLLVM_ENABLE_PROJECTS=mlir \
   -DLLVM_BUILD_EXAMPLES=ON \
   -DLLVM_TARGETS_TO_BUILD="Native" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON
cmake --build . --target check-mlir
```

Caso não tenha o `Ninja` instalado, o que torna a compilação mais rápida por usar paralelismo, remova essa flag do comando cmake:

```
cmake ../llvm \
   -DLLVM_ENABLE_PROJECTS=mlir \
   -DLLVM_BUILD_EXAMPLES=ON \
   -DLLVM_TARGETS_TO_BUILD="Native" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON
```

Coloque o diretório bin (`llvm-project/build/bin`) no seu `PATH`. Mais informações podem ser encontradas na página do MLIR: [getting started](https://mlir.llvm.org/getting_started/).



# Exemplos MLIR

Nada melhor do que aprender com exemplos

## Função para somar dois valores

No exemplo abaixo, duas funções são implementadas usando o dialeto `func`,  `@add_int` e `@add_float`. Nesse dialeto, existem operações como `func`, `return` e `call`. Ambas funções recebem dois argumentos como entrada, `%a` e `%b`. A função para somar inteiros define que o tipo de cada um dos argumentos é um inteiro de 32 bits (`i32`), portanto a assinatura é `@add_int(%a: i32, %b: i32)`. A função também retorna um valor, lembrando que operações (que inclui funções) podem retornas entre zero ou mais valores. O tipo da cada valor retornado deve ser especificado antes do corpo da função, com uso da "seta para direita" `->`. Logo, a assinatura completa fica `@add_int(%a: i32, %b: i32) -> (i32)`.

Uma outra função é implementada, que é o ponto de entrada da execução: `main`. Além disso, um outra função é declarada para imprimir saída na tela (`printf`), que é implementada pela `libc`. A função `main` declara algumas constantes usando o dialeto `arith`, e faz a chamada das funções usadas anteriormente. Além disso, foram criadas duas constantes globais que são as strings que usaremos no `printf`.

```
module {
  // Para usar o printf
  llvm.func @printf(!llvm.ptr, ...) -> i32

  // String de formatacao
  llvm.mlir.global private constant @fmt_msg_int("%d\0A\00")
  llvm.mlir.global private constant @fmt_msg_float("%f\0A\00")

  func.func @add_int(%a: i32, %b: i32) -> (i32){
    %r = arith.addi %a, %b : i32
    func.return %r : i32
  }

  func.func @add_float(%a: f32, %b: f32) -> (f32){
    %r = arith.addf %a, %b : f32
    func.return %r : f32
  }

  func.func @main() -> (i32){
    %c0 = arith.constant 5: i32
    %c1 = arith.constant 17: i32
    %c0f = arith.constant 5.5: f32
    %c1f = arith.constant 17.5: f32

    %rint = func.call @add_int(%c0, %c1) : (i32, i32) -> i32

    %fmt_ptr_int = llvm.mlir.addressof @fmt_msg_int : !llvm.ptr
    %pri = llvm.call @printf(%fmt_ptr_int, %rint) 
      vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr, i32) -> i32

    %rfloat = func.call @add_float(%c0f, %c1f) : (f32, f32) -> f32
    %rdouble = arith.extf %rfloat : f32 to f64

    %fmt_ptr_float = llvm.mlir.addressof @fmt_msg_float : !llvm.ptr
    %prf = llvm.call @printf(%fmt_ptr_float, %rdouble) 
      vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr, f64) -> i32
    return %rint : i32
  }
}
```

Notem que o exemplo tem diversos dialetos sendo usados, exemplificando a ideia de MLIR ser multi-nível. Outro ponto por trás do MLIR é a conversão progressiva do código nos dialetos de mais baixo nível. Para isso, podemos usar a ferramenta `mlir-opt`. Por exemplo, para converter os dialetos `func` e `arith` do código acima, e considerando que o nome do arquivo com o código é `func_add.mlir`, rodamos o seguinte comando: `mlir-opt func_add.mlir -convert-arith-to-llvm -convert-func-to-llvm`. A saída está abaixo.

```
module {
  llvm.func @printf(!llvm.ptr, ...) -> i32
  llvm.mlir.global private constant @fmt_msg_int("%d\0A\00") {addr_space = 0 : i32}
  llvm.mlir.global private constant @fmt_msg_float("%f\0A\00") {addr_space = 0 : i32}
  llvm.func @add_int(%arg0: i32, %arg1: i32) -> i32 {
    %0 = llvm.add %arg0, %arg1 : i32
    llvm.return %0 : i32
  }
  llvm.func @add_float(%arg0: f32, %arg1: f32) -> f32 {
    %0 = llvm.fadd %arg0, %arg1 : f32
    llvm.return %0 : f32
  }
  llvm.func @main() -> i32 {
    %0 = llvm.mlir.constant(5 : i32) : i32
    %1 = llvm.mlir.constant(17 : i32) : i32
    %2 = llvm.mlir.constant(5.500000e+00 : f32) : f32
    %3 = llvm.mlir.constant(1.750000e+01 : f32) : f32
    %4 = llvm.call @add_int(%0, %1) : (i32, i32) -> i32
    %5 = llvm.mlir.addressof @fmt_msg_int : !llvm.ptr
    %6 = llvm.call @printf(%5, %4) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, i32) -> i32
    %7 = llvm.call @add_float(%2, %3) : (f32, f32) -> f32
    %8 = llvm.fpext %7 : f32 to f64
    %9 = llvm.mlir.addressof @fmt_msg_float : !llvm.ptr
    %10 = llvm.call @printf(%9, %8) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, f64) -> i32
    llvm.return %4 : i32
  }
}
```

Por fim, podemos traduzir o MLIR acima, que está usando apenas o dialeto LLVM, para LLVM IR usando o comando `mlir-translate func_add_llvm.mlir -mlir-to-llvmir`. O resultado final está abaixo, que pode ser compilado com o clang, ou executado com a ferramenta `lli`.

```
; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@fmt_msg_int = private constant [4 x i8] c"%d\0A\00"
@fmt_msg_float = private constant [4 x i8] c"%f\0A\00"

declare i32 @printf(ptr, ...)

define i32 @add_int(i32 %0, i32 %1) {
  %3 = add i32 %0, %1
  ret i32 %3
}

define float @add_float(float %0, float %1) {
  %3 = fadd float %0, %1
  ret float %3
}

define i32 @main() {
  %1 = call i32 @add_int(i32 5, i32 17)
  %2 = call i32 (ptr, ...) @printf(ptr @fmt_msg_int, i32 %1)
  %3 = call float @add_float(float 5.500000e+00, float 1.750000e+01)
  %4 = fpext float %3 to double
  %5 = call i32 (ptr, ...) @printf(ptr @fmt_msg_float, double %4)
  ret i32 %1
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
```


### mlir-opt e mlir-translate

Os comandos completos para sair do MLIR e chegar no LLVM IR são os seguintes:

```
mlir-opt func_add.mlir -convert-arith-to-llvm -convert-func-to-llvm -reconcile-unrealized-casts -o func_add_opt.mlir
mlir-translate func_add_opt.mlir -mlir-to-llvmir -o func_add_opt.ll
```

## Exemplo memref e scf

O exemplo abaixo mostra uma função que recebe como argumentos de entrada três memref (dialeto `memref` representa buffers de memória, que podem ser multidimensionais), que são arrays unidimensionais com dez inteiros de 32 bits `<10xi32>`, e não tem nenhuma saída. A função soma os dois primeiros arrays e guarda o resultado no terceiro array, usando o laço for do dialeto `scf`.

```
  func.func @array_add(%arg0: memref<10xi32>, %arg1: memref<10xi32>, %arg2: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    scf.for %arg3 = %c0 to %c10 step %c1 {
      %0 = memref.load %arg0[%arg3] : memref<10xi32>
      %1 = memref.load %arg1[%arg3] : memref<10xi32>
      %2 = arith.addi %0, %1 : i32
      memref.store %2, %arg2[%arg3] : memref<10xi32>
    }

    return
  }

```

Podemos converter o dialeto `scf` e transformá-lo para algo menos estruturado e comum em assembly, que é o dialeto `cf` que usa apenas desvios. O resultado pode ser visto abaixo.

```
  func.func @array_add(%arg0: memref<10xi32>, %arg1: memref<10xi32>, %arg2: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index
    cf.br ^bb1(%c0 : index)
  ^bb1(%0: index):  // 2 preds: ^bb0, ^bb2
    %1 = arith.cmpi slt, %0, %c10 : index
    cf.cond_br %1, ^bb2, ^bb3
  ^bb2:  // pred: ^bb1
    %2 = memref.load %arg0[%0] : memref<10xi32>
    %3 = memref.load %arg1[%0] : memref<10xi32>
    %4 = arith.addi %2, %3 : i32
    memref.store %4, %arg2[%0] : memref<10xi32>
    %5 = arith.addi %0, %c1 : index
    cf.br ^bb1(%5 : index)
  ^bb3:  // pred: ^bb1
    return
  }
```

O exemplo completo, que usa a função acima, está abaixo.

```
module {
  // Para usar o printf
  llvm.func @printf(!llvm.ptr, ...) -> i32

  // String de formatacao
  llvm.mlir.global private constant @fmt_int("%d \00")
  llvm.mlir.global private constant @fmt_newline("\0A\00")

  func.func @array_add(%arg0: memref<10xi32>, %arg1: memref<10xi32>, %arg2: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    scf.for %arg3 = %c0 to %c10 step %c1 {
      %0 = memref.load %arg0[%arg3] : memref<10xi32>
      %1 = memref.load %arg1[%arg3] : memref<10xi32>
      %2 = arith.addi %0, %1 : i32
      memref.store %2, %arg2[%arg3] : memref<10xi32>
    }

    return
  }

  func.func @array_init(%arg0: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    scf.for %arg3 = %c0 to %c10 step %c1 {
      %arg3_i32 = index.casts %arg3 : index to i32
      memref.store %arg3_i32, %arg0[%arg3] : memref<10xi32>
    }

    return
  }

  func.func @array_print(%arg0: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    %fmt_ptr = llvm.mlir.addressof @fmt_int : !llvm.ptr
    scf.for %arg3 = %c0 to %c10 step %c1 {
      %0 = memref.load %arg0[%arg3] : memref<10xi32>
      %pr = llvm.call @printf(%fmt_ptr, %0) 
        vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr, i32) -> i32
    }
    %fmt_nl = llvm.mlir.addressof @fmt_newline : !llvm.ptr
      %pr = llvm.call @printf(%fmt_nl) 
        vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr) -> i32

    return
  }

  func.func @main() -> (i32){
    %c0 = arith.constant 0 : i32

    %A = memref.alloca() : memref<10xi32>
    %B = memref.alloca() : memref<10xi32>
    %C = memref.alloca() : memref<10xi32>

    func.call @array_init(%A) : (memref<10xi32>) -> ()
    func.call @array_init(%B) : (memref<10xi32>) -> ()

    func.call @array_print(%A) : (memref<10xi32>) -> ()

    func.call @array_add(%A, %B, %C) : (memref<10xi32>, memref<10xi32>, memref<10xi32>) -> ()

    func.call @array_print(%C) : (memref<10xi32>) -> ()

    return %c0 : i32
  }
}
```

### mlir-opt e mlir-translate

Os comandos completos para sair do MLIR e chegar no LLVM IR são os seguintes:

```
mlir-opt array_add.mlir -finalize-memref-to-llvm -convert-scf-to-cf -convert-cf-to-llvm -convert-arith-to-llvm -convert-index-to-llvm -convert-func-to-llvm -reconcile-unrealized-casts -o array_add_opt.mlir
mlir-translate array_add_opt.mlir -mlir-to-llvmir -o array_add_opt.ll
```
