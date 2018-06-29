%{
#include "parser.h"
#include "y.tab.h"
#include <string.h>

extern int lineno;
%}

ws        [ \t]+
comment   #.*
value       (\"[^\"\n]*[\"\n])|(([0-9]+)|(0-9)*\.[0-9]+)
id        [a-zA-Z][a-zA-Z0-9]*
nl        \n

%%

{ws}      ;
{comment} ;
{value} {

    if(yytext[0] == '"'){
        yylval.string = strdup(yytext);
        if(yylval.string[yyleng-1] != '"')
	        warning("Unterminated character string",(char *)0);
        return STRING;
    }
    else{
        yylval.string = malloc(strlen(yytext) + 2);
        strcpy(yylval.string, yytext);
        if(strstr(".", yytext) == NULL)
            strcat(yylval.string, ".");
        return NUMBER;
    }
    }
ESTE            { return VAR; }
CAMISAKI        { return IF; }
PANTALONCITO     { return THEN; }
QUECORTECITO    { return ELSE; }
ANIANIAY        { return END_IF; }
MIENTRAS        { return WHILE; }
VOSSEGUIME      { return DO; }
GRACIASPERRO    { return END_WHILE; }
NIAPALOS        { return NOT; }
I               { return AND; }
O               { return OR; }
IGUAL           { return EQUALS; }
NOIGUAL         { return NOT_EQUALS; }
REALFA          { return GREATER; }
MASALFA         { return GREATER_EQ; }
REBETA          { return LESSER; }
MENOSBETA       { return LESSER_EQ; }
\+               { return SUM; }
-               { return SUB; }
\*               { return MUL; }
\/               { return DIV; }
%               { return MOD; }
SELADADE        { return ASSIGN; }
XD              { return END_LINE; }
\(               { return PARENTHESIS_OPENED; }
\)               { return PARENTHESIS_CLOSED; }
PIPI            { return PRINT; }
{id}            { yylval.symp = symlook(yytext);
                  return ID;
                }
{nl}            { lineno++; }
.               { return yytext[0]; }
%%
