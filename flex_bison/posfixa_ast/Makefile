posfixa:
	bison -d posfixa.y
	flex posfixa.l
	clang -o posfixa utils.c posfixa.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c posfixa posfixa.tab.c posfixa.tab.h
