    % {
/*
 * A parser for the basic grammar to use for recognizing English sentences.
*/
#include <stdio.h>
# define NOUN 257
# define PRONOUN 258
# define VERB 259
# define ADVERB 260
# define ADJECTIVE 261
# define PREPOSITION 262
# define CONJUNCTION 263
#define NOUN 257
#define PRONOUN 258
#define VERB 259
#define ADVERB 260
#define ADJECTIVE 261
#define PREPOSITION 262
#define CONJUNCTION 263
%}
%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION

%% 
sentence : subject VERB object { printf("Sentence is valid.\n"); }
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