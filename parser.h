#ifndef __PARSER_H
#define __PARSER_H

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
/*
Map<String, Value> varMap;

Value {
    double numValue;
    string strValue;
}

num add 1 //.dank

__dank_getvar("num").numValue = 1 //.c

var asd //.dank

__dank_define("asd")

*/


struct symtab *symlook();


#endif
