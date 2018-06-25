%{
/*
 * A parser for the basic grammar to use for recognizing English sentences.
*/
#include <stdio.h>
%}

%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION

%%
sentence: subject VERB object { printf("Sentence is valid.\n"); }
    ;

subject:    NOUN 
    |       PRONOUN 
    ;

object:     NOUN
    ;
%%

extern FILE *yyin;

main()
{
    while(!feof(yyin)){
        yyparse();
    }
}

yyertor(s)
char *s;
{
    fprintf(stderr,"%s\n",s);
}