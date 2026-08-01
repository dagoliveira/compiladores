# LLVM-IR

A principal referência para qualquer coisa relacionada ao "assembly" do LLVM está na referência da linguagem: [LangRef](https://llvm.org/docs/LangRef.html). Um bom tutorial, em inglês, é o [A Gentle Introduction to LLVM IR](https://mcyoung.xyz/2023/08/01/llvm-ir/).

Uma introdução básica está disponível [aqui](./llvm-ir_intro.md), onde alguns comandos básicos são demonstrados, chegando até um código completo para calcular o fatorial de forma recursvia e iterativa. 

Oo códigos do fatorial na forma recursiva e iterativa estão [aqui](./codigos/). O código espera uma entrada do teclado, e imprime o resultado do fatorial na tela. Para executar o código, é possível compilá-lo com o [clang](https://clang.llvm.org/), ou interpretá-lo com a ferramenta [lli](https://llvm.org/docs/CommandGuide/lli.html). De preferência, utilize o LLVM (ou clang) da versão 15 ou superior.


Alguns vídeos mostrando como escrever e executar LLVM-IR estão disponíveis [nesta playlist do youtube](https://www.youtube.com/playlist?list=PLNH5D_GBXFJPc6u-LDsq4W3oMGxiL6N4k).

Como usar `scanf` e `printf` é brevemente explicado [neste arquivo](./llvm-ir_scanf_printf.md).

Por fim, para usar a API em C++, e não ficar escrevendo código diretamente em LLVM-IR, veja [este tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html) publicado pela própria LLVM Foundation. O tutorial mostra como criar uma linguagem de programação simples, chamada Kaleidoscope. Veja especialmente o [Capítulo 3](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/LangImpl03.html).
