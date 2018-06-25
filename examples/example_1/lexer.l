%{
/*
 * A lexer for the high-level parser
 */

#include "y.tab.h" /* token codes from the parser */
#define LOOKUP 0 /* default - not a defined word type */
int state;
%}

%%

\n { state = LOOKUP; }
\. \n { state = LOOKUP;
        return 0; /* end of sentence */ }
^verb { state = VERB; }
^adj { state = ADJECTIVE; }
^adv { state = ADVERB; }
^noun { state = NOUN; }
^prep { state = PREPOSITION; }
^pron { state = PRONOUN; }
^conj { state = CONJUNCTION; }

[a-zA-Z]+ {
            if (state != LOOKUP) {
            add_word(state, yytext);
            } else {
            switch (lookUp_word(yytext)){
            case VERB:
                return (VERB);
            case ADJECTIVE:
                return (ADJECTIVE);
            case ADVERB:
                return (ADVERB);
            case NOUN:
                return (NOUN);
            case PREPOSITION:
                return (PREPOSITION);
            case PRONOUN:
                return (PRONOUN);
            case CONJUNCTION:
                return (CONJUNCTION);
            default:
                printf("%s: don't reccgnize\n", yytext);
                /* don't return, just ignore it */
            }
            }
          }
. ;
% %

/* define a linked list of words and types */
struct word
{
    char *word_name;
    int word_type;
    struct word *next;
};
struct word *word_list;/* first element in word list */
extern void *malloc();

int add_word(int type, char* word)
{
    struct word *wp;
    if(lookupWord(word) != LOOKUP){
        printf("WARNING: WORD %s IS ALREADY DEFINED \n", word);
        return 0;
    }
    wp = (struct word *) malloc(sizeof(struct word));
    wp-> next = word_list;

    /* we copy the word */
    wp->word_name = (char *) malloc(sizeof(strlen(word)+1);
    strcopy(wp->word_name, word);
    wp->word_type = type;
    word_list = wp;
    return 1; 
}

int lookup_word(char *word)
{
    struct *wp = word_list;

    for(; wp; wp->next)
    {
        if(strcmp(wp->word_name, word) == 0)
            return wp->word_type
    }
    return LOOKUP;
}