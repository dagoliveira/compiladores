#ifndef COMPILADOR_H
#define COMPILADOR_H

#include<stdio.h>

int yyerror(const char *s);

extern FILE *log_file;
extern FILE *out_file;

#endif
