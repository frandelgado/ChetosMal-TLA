#ifndef __PARSER_H
#define __PARSER_H

#define NSYMS 20 /* maximum number of symbols */

#define UNDECLARED 0
#define DECLARED 1

typedef enum { TYPE_UNDEF, TYPE_NUMBER, TYPE_STRING } var_type_t;

typedef enum { OP_GREATER, OP_GREATER_EQ, OP_LESSER, OP_LESSER_EQ, OP_EQUALS, OP_NOT_EQ } op_t;

struct symtab
{
    char *name;
    char *str;
    var_type_t var_type;
    int isDeclared;
} symtab[NSYMS];

struct value{
    char * str;
    var_type_t var_type;
};

struct symtab *symlook();

void warning(char *s, char *t);
int yywrap();

#endif
