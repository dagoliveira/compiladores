# CI1210 - Projetos Digitais e Microprocessadores

Bem-vindo(a) ao curso de *Construção de Compiladores*, ofertado pelo [DInF](https://web.inf.ufpr.br/dinf/) (Departamento de Informática) da UFPR (Universidade Federal do Paraná)

## Objetivo

O aluno deverá ser capaz de compreender as técnicas e módulos utilizados para a construção de um compilador.

## Conteúdo

### Fase 1 - Parte mais prática, ferramental e implementação de um projeto
- Introdução básica: [link](./aulas/introducao.pdf)
- Exercício parser manual (lab): [link](./analise_sintatica/exercicio_pratico_top_down/)
- SSA, fluxo de controle e otimizações (aula teórica)
- LLVM-IR [link](./llvm/README.md) e MLIR (teórica e lab)
- Tabela de símbolos e análise semântica (aula teórica)
- Sistema de tipos (aula teórica)
- ANTLR 4 + MLIR (lab para implementar um projeto de compilador)

### Fase 2 - Parte mais teórica sobre análise sintática

- Revisão de Gramáticas, linguagens, ambiguidades 
- Análise Sintática Descendente (Top-Down) 
- Análise Sintática Ascendente (Botton-up) 
- SLR(0)
- SLR(1)
- LR(1)

## Bibliografia

### Geral
- Alfred V. Aho, S. Lam Monica, and D. Ullman Jeffrey. "Compilers principles, techniques & tools". Pearson Education, 2007. (Livro do dragão), [2 edição disponível no Internet Archive](https://archive.org/details/compiladores-principios-tec) e versão em português disponível na biblioteca.
- Andrew W. Appel. "Modern compiler implementation in ML." Cambridge University Press, 2004. (Livro do tigre), tem versão em C e Java.
- Keith D. Cooper, and Linda Torczon. "Construindo Compiladores". Morgan Kaufmann, 2013.
- Douglas Thain. "Introduction to Compilers and Language Design". Publicado de forma independente e disponível gratuitamente [aqui](https://dthain.github.io/books/compiler/).
- [Tomasz Kowaltowski. "Implementação de Linguagens de Programação". Guanabara Dois, 1983](http://www.ic.unicamp.br/~tomasz/ilp/)

### ANTLR 4
- Parr, Terence. The Definitive ANTLR 4 Reference. "Pragmatic Bookshelf", 2013. [Documentação](https://github.com/antlr/antlr4/blob/master/doc/index.md)

### Flex e Bison (Ferramentas que não são mais usadas)
- Levine, John. Flex & Bison: Text Processing Tools. "O'Reilly Media, Inc.", 2009.


