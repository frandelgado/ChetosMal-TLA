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
var             { return VAR; }
if              { return IF; }
then            { return THEN; }
else            { return ELSE; }
end_if          { return END_IF; }
while           { return WHILE; }
do              { return DO; }
end_while       { return END_WHILE; }
not             { return NOT; }
and             { return AND; }
or              { return OR; }
eq              { return EQUALS; }
not_eq          { return NOT_EQUALS; }
greater         { return GREATER; }
greater_eq      { return GREATER_EQ; }
lesser          { return LESSER; }
lesser_eq       { return LESSER_EQ; }
add             { return SUM; }
sub             { return SUB; }
mul             { return MUL; }
div             { return DIV; }
mod             { return MOD; }
assign          { return ASSIGN; }
end_line        { return END_LINE; }
par_open        { return PARENTHESIS_OPENED; }
par_close       { return PARENTHESIS_CLOSED; }
print           { return PRINT; }
append_a_char   { return APPENDCHAR; }
{id}            { yylval.symp = symlook(yytext);
                  return ID;
                }
{nl}            { lineno++; }
.               { return yytext[0]; }
%%
