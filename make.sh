#!/bin/sh

bison -d calc.y
flex calc.l
g++ lex.yy.c calc.tab.c -o calc

#rm lex.yy.c $1.tab.h $1.tab.c
