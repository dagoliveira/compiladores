# Como implementar read e write em LLVM-IR

Uma forma, simples/simplória, de adicionar as funções de scanf e printf, seria declará-las da seguinte forma:

```
declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c\"%%d\\00\", align 1
@write_int = private unnamed_addr constant [4 x i8] c\"%%d\\0A\\00\", align 1
@read_float = private unnamed_addr constant [3 x i8] c\"%%f\\00\", align 1
@write_float = private unnamed_addr constant [4 x i8] c\"%%f\\0A\\00\", align 1
```

Dessa forma, podemos usar as funções `__isoc99_scanf` e `printf` da libc em nosso programa.  Para isso, chamamos a função de scanf com a string de formatação adequada (read\_int ou read\_float) e um ponteiro para memória alocada. De igual modo, para imprimir na tela, chamamos a função de printf com a string de formatação adequada (write\_int ou write\_float) e o ponteiro com o valor a ser impresso.

## Inteiros

Considere o seguinte programa em C:

```
#include<stdio.h>

int main(){
    int x;
    scanf("%d", &x);
    x = x + 1;
    printf("%d\n",x);
    return 0;
}
```

Em LLVM, poderíamos traduzi-lo da seguinte forma:

```
declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@read_float = private unnamed_addr constant [3 x i8] c"%f\00", align 1
@write_float = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1


define dso_local i32 @main() local_unnamed_addr #0 {
  %1 = alloca i32
  %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr @read_int, ptr %1)
  %3 = load i32, ptr %1
  %4 = add nsw i32 %3, 1
  store i32 %4, ptr %1
  %5 = call i32 (ptr, ...) @printf(ptr @write_int, i32 %4)
  ret i32 0
}
```

## Ponto Flutuante

Um detalhe quando se trata de ponto flutuante é a necessidade de alterar o valor para `double`, caso contrário apenas um 0 será impresso na tela. Portanto, o seguinte código em C;

```
#include<stdio.h>

int main(){
    float x;
    scanf("%f", &x);
    x = x + 1;
    printf("%f\n",x);
    return 0;
}
```

Pode ser traduzido para LLVM da seguinte forma:

```
declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@read_float = private unnamed_addr constant [3 x i8] c"%f\00", align 1
@write_float = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1


define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca float, align 4
  store i32 0, ptr %1, align 4
  %3 = call i32 (ptr, ...) @__isoc99_scanf(ptr  @read_float, ptr  %2)
  %4 = load float, ptr %2, align 4
  %5 = fadd float %4, 1.000000e+00
  store float %5, ptr %2, align 4
  %6 = load float, ptr %2, align 4
  %7 = fpext float %6 to double
  %8 = call i32 (ptr, ...) @printf(ptr  @write_float, double  %7)
  ret i32 0
}
```

Note que precisamos fazer a instrução `fpext` antes de chamar o printf.
