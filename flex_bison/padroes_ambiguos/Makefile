CC=clang
wc:
	flex ambiguos.l
	$(CC) lex.yy.c -lfl -o ambiguo

clean:
	rm -f lex.yy.c ambiguo
