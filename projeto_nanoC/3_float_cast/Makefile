compilador: compilador.y compilador.l tabela_simbolos.c code_gen.c
	bison -d compilador.y
	flex compilador.l
	clang -o compilador tabela_simbolos.c code_gen.c compilador.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c compilador compilador.tab.c compilador.tab.h
