calculadora:
	bison -d calculadora.y
	flex calculadora.l
	clang -o calculadora utils.c calculadora.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c calculadora calculadora.tab.c calculadora.tab.h
