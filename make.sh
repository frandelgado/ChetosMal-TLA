#!/bin/bash
echo -e "\e[33mBuilding lexer\e[0m"
lex lexer.l
echo -e "\e[33mBuilding parser\e[0m"
yacc -d parser.y
echo -e "\e[33mCompiling lexer and parser\e[0m"
cc -c lex.yy.c y.tab.c
echo -e "\e[33mLinking lexer and parser\e[0m"
cc -o dankcompiler lex.yy.o y.tab.o -ll