%{
#include "parser.h"
#include <string.h>

extern int lineno;
%}

ws        [ \t]+
comment   #.*
var       (\"[^\"\n]*[\"\n])|(([0-9]+)|(0-9)*\.[0-9]+)
id        [a-zA-Z][a-zA-Z0-9]*
nl        \n

%%

{ws}      ;
{comment} ;
{var} { 
    
    if(yytext[0] == '"'){
        yylval.string = strdup(yytext+1); /* skip open quote */
        if(yylval.string[yyleng-2] != '"')
	        warning("Unterminated character string",(char *)0);
	    else
	        yylval.string[yyleng-2] = '\0'; /* remove close quote */
            return STRING; 
    }
    else{
        yylval.number = atoi(yytext);
        return NUMBER;
    }
    }
var             { return VAR; }
while_begin     { return OPEN_LOOP; }
greater         { return GREATER; }
smaller         { return LESSER; }
addition        { return SUM; }
substraction    { return SUB; }
multiplication  { return MUL; }
division        { return DIV; }
while_end       { return CLOSE_LOOP; }
assignment      { return ASSIGN; }
end_line        { return END_LINE; }
end             { return END; }
{id}            { yylval.string = strdup(yytext);
                  return ID;
                }
{nl}            { lineno++; }
.               { return yytext[0]; }
%%
