# LLVM-IR

A principal referência para qualquer coisa relacionada ao "assembly" do LLVM está na referência da linguagem: [LangRef](https://llvm.org/docs/LangRef.html). Um bom tutorial, em inglês, é o [A Gentle Introduction to LLVM IR](https://mcyoung.xyz/2023/08/01/llvm-ir/).

Uma introdução básica está disponível [aqui](./llvm_intro.pdf), onde alguns comandos básicos são demonstrados, chegando até um código completo para calcular o fatorial de forma recursvia. 

O código do fatorial recursivo está [aqui](./codigos/fat_rec.ll). O código espera uma entrada do teclado, e imprime o resultado do fatorial na tela. Para executar o código, é possível compilá-lo com o [clang](https://clang.llvm.org/), ou interpretá-lo com a ferramenta [lli](https://llvm.org/docs/CommandGuide/lli.html). De preferência, utiliza o LLVM (ou clang) da versão 15 ou superior (foi testado na versão 19).


Alguns vídeos mostrando como escrever e executar LLVM-IR estão disponíveis [nesta playlist do youtube](https://www.youtube.com/playlist?list=PLNH5D_GBXFJPc6u-LDsq4W3oMGxiL6N4k).
