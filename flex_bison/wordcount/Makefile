CC=clang
wc:
	flex wc.l
	$(CC) lex.yy.c -lfl -o wc_flex

clean:
	rm -f lex.yy.c wc_flex
