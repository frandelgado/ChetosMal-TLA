#define NSYMS 20 /* maximum number of symbols */

struct symtab
{
    char *name;
    char *stringVal;
    double doubleVal;
    int isDeclared;
} symtab[NSYMS];

struct variable{
    int vartype;l
} vp;

struct symtab *symlook();
