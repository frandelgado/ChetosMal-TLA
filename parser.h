#define NSYMS 20 /* maximum number of symbols */

enum var_type_t { UNDEF, NUMBER, STRING };

enum op_t { GREATER, GREATER_EQ, LESSER, LESSER_EQ, EQUALS, NOT_EQ };

struct symtab
{
    char *name;
    char *str;
    var_type_t var_type;
    int isDeclared; //???
} symtab[NSYMS];

struct value{
    char * str;
    var_type_t var_type;
};



struct symtab *symlook();
