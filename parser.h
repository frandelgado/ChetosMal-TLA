#define NSYMS 20 /* maximum number of symbols */

enum var_type_t { UNDEF, NUMBER, STRING };

struct symtab
{
    char *name;
    char *stringVal;
    double doubleVal;
    int isDeclared;
} symtab[NSYMS];

struct value{
    char * str;
    var_type_t var_type;
};



struct symtab *symlook();
