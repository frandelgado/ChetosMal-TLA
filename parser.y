%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.h"
#include "main.h"

#define FLOAT_DEC_PTS "%.10f"

int parsing_done = 1; 
int yydebug = 1;
FILE *yyout;
char * progname;

void warning(char *s, char *t);
void yyerror (char const *s);
void symIsDeclared(char const *s);
void symDeclare(char const *s);
char * concat(char *str1, char *str2);
struct value * operate(struct value *v1, struct value *v2, char *op);
struct value * sum(struct value *v1, struct value *v2);
struct value * sub(struct value *v1, struct value *v2);
struct value * mul(struct value *v1, struct value *v2);
struct value * divi(struct value *v1, struct value *v2);
struct value * mod(struct value *v1, struct value *v2);
char * writeBool(struct value * v1, op_t operation, struct value * v2);

%}

%union {
    char    *string;     /* string buffer */
    double    number;          /* command value */
	struct symtab *symp;
	struct value *valuep;
	op_t op
};

%token <string> STRING
%token <symp> ID
%token <string> NUMBER 
%token <cmd> SUM SUB MUL DIV MOD VAR
%token <cmd> ASSIGN GREATER GREATER_EQ LESSER LESSER_EQ EQUALS NOT_EQUALS
%token <cmd> NOT AND OR
%token <cmd> END_LINE PRINT
%token <cmd> PARENTHESIS_OPENED PARENTHESIS_CLOSED
%token <cmd> IF THEN ELSE END_IF WHILE DO END_WHILE
%type <string> statements statement
%type <valuep> value operation
%type <string> bool_exp logic_op condition
%type <op> comparation

%start file

%%

file: 		  file statement { fprintf(yyout, $2); free($2); }
			| statement { fprintf(yyout, $1); free($1); }
			;

statements:   statements statement { $$ = realloc($1, strlen($1) + strlen($2) + 1); strcat($$, $2); free($2); }
			| statement { $$ = $1; }
			;

statement:   
			  VAR ID END_LINE { 
				  		if($2->var_type != TYPE_UNDEF) {
							yyerror("Variable already defined");
						} else {
							$$ = malloc(strlen($2->name) + 18); $$[0] = 0;
							sprintf($$, "__dank_define(%s);\n", $2->name);
						}
			  }
			| VAR ID ASSIGN value END_LINE {
						if($2->var_type != TYPE_UNDEF) {
							yyerror("Variable already defined");
						} else {
							char * def = malloc(strlen($2->name) + 18);
							sprintf(def, "__dank_define(\"%s\");\n", $2->name);
							char * assig = malloc(strlen($2->name) + strlen($4->str) + 40);
							switch($4->var_type) {
								case TYPE_UNDEF:
									yyerror("Attempt to use an undefined variable");
									break;
								case TYPE_STRING:
									$2->var_type = TYPE_STRING;
									sprintf(assig, "__dank_getvar(\"%s\")->strValue = %s;\n", $2->name, $4->str);
									break;
								case TYPE_NUMBER:
									$2->var_type = TYPE_STRING;
									sprintf(assig, "__dank_getvar(\"%s\")->numValue = %s;\n", $2->name, $4->str);
									break;
							}
							$$ = malloc(strlen(def) + strlen(assig) + 1);
							sprintf($$, "%s%s", def, assig);
							free(def);
							free(assig);
							free($4->str);
						}
			}
            | ID ASSIGN value END_LINE {
						$$ = malloc(strlen($1->name) + strlen($3->str) + 36);
						switch($3->var_type) {
							case TYPE_UNDEF:
								yyerror("Attempt to use an undefined variable");
								break;
							case TYPE_STRING:
								sprintf($$, "__dank_getvar(\"%s\")->strValue = %s;\n", $1->name, $3->str);
								break;
							case TYPE_NUMBER:
								sprintf($$, "__dank_getvar(\"%s\")->numValue = %s;\n", $1->name, $3->str);
								break;
						}
						free($3->str);
			}
			| PRINT value END_LINE {
						$$ = malloc(strlen($2->str) + 19);
						switch($2->var_type) {
							case TYPE_UNDEF:
								yyerror("Attempt to use an undefined variable");
								break;
							case TYPE_STRING:
								sprintf($$, "printf(\"%%s\n\", %s);\n", $2->str);
								break;
							case TYPE_NUMBER:
								sprintf($$, "printf(\"%%g\n\", %s);\n", $2->str);
								break;
						}
						free($2->str);
			}
			| IF condition THEN statements END_IF {
						$$ = malloc(strlen($2) + strlen($4) + 7); $$[0] = 0;
						strcat($$, "if(");
						strcat($$, $2);
						strcat($$, "){");
						strcat($$, $4);
						strcat($$, "}");
						free($2);
						free($4);}
			| IF condition THEN statements ELSE statements END_IF {
						$$ = malloc(strlen($2) + strlen($4) + strlen($6) + 13); $$[0] = 0;
						strcat($$, "if(");
						strcat($$, $2);
						strcat($$, "){");
						strcat($$, $4);
						strcat($$, "}else{");
						strcat($$, $6);
						strcat($$, "}");
						free($2);
						free($4);
						free($6);}
			| WHILE condition DO statements END_WHILE {
						$$ = malloc(strlen($2) + strlen($4) + 10); $$[0] = 0;
						strcat($$, "while(");
						strcat($$, $2);
						strcat($$, "){");
						strcat($$, $4);
						strcat($$, "}");
						free($2);
						free($4);}
			;

value:	 	  STRING {$$->var_type = TYPE_STRING; $$->str = strdup($1);}
			| NUMBER {$$->var_type = TYPE_NUMBER; $$->str = strdup($1);}
			| operation {$$->var_type = $1->var_type; $$->str = $1->str;}
			| ID {
						$$->str = malloc(strlen($1->name) + 33);
						switch($1->var_type) {
							case TYPE_UNDEF:
								yyerror("Attempt to use an undefined variable");
								break;
							case TYPE_STRING:
								sprintf($$->str, " __dank_getvar(\"%s\")->strValue ", $1->name);
								$$->var_type = TYPE_STRING;
								break;
							case TYPE_NUMBER:
								sprintf($$->str, " __dank_getvar(\"%s\")->numValue ", $1->name);
								$$->var_type = TYPE_NUMBER;
								break;
						}
			}
			;

		
condition: 	  NOT condition { 	$$ = malloc(strlen($2) + 2); $$[0] = 0; 
								strcat($$, "!"); strcat($$, $2);
								free($2); }
			| PARENTHESIS_OPENED condition logic_op condition PARENTHESIS_CLOSED {//NO HACER FREE DE logic_op
								$$ = malloc(strlen($2) + strlen($3) + strlen($4) + 3); $$[0] = 0;
								strcat($$, "(");
								strcat($$, $2);
								strcat($$, $3);
								strcat($$, $4);
								strcat($$, ")");
								free($2);
								free($4);}
			| bool_exp 		{ $$ = $1; }
			;

bool_exp: 	  value comparation value 		{ $$ = writeBool($1, $2, $3); };

comparation:  GREATER 		{ $$ = OP_GREATER; }
			| LESSER  		{ $$ = OP_LESSER; }
			| LESSER_EQ 	{ $$ = OP_LESSER_EQ; }
			| GREATER_EQ 	{ $$ = OP_GREATER_EQ; }
			| EQUALS 		{ $$ = OP_EQUALS; }
			| NOT_EQUALS	{ $$ = OP_NOT_EQ; }
			;

logic_op: 	  AND		{ $$ = "&&"; } 
			| OR 		{ $$ = "||"; }
			;

operation:    value SUM value { $$ = sum($1, $3); } 
            | value SUB value { $$ = sub($1, $3); }
            | value MUL value { $$ = mul($1, $3); }
            | value DIV value { $$ = divi($1, $3); }
            | value MOD value { $$ = mod($1, $3); }
            ;
%%


char * writeBool(struct value * v1, op_t operation, struct value * v2) {
	char * out;
	char * op_str;
	switch(operation) {
			case OP_EQUALS:
				op_str = "==";
				break;
			case OP_NOT_EQ:
				op_str = "!=";
				break;
			case OP_GREATER:
				op_str = "!=";
				break;
			case OP_GREATER_EQ:
				op_str = "!=";
				break;
			case OP_LESSER:
				op_str = "!=";
				break;
			case OP_LESSER_EQ:
				op_str = "!=";
				break;
		}
	if(v1->var_type != v2->var_type) {
		yyerror("Attempt to compare number with string");
	} else if (v1->var_type == TYPE_STRING) {
		out = malloc(strlen(v1->str) + strlen(v2->str) + 21);
		sprintf(out, " strcmp(%s, %s) %s 0 ", v1->str, v2->str, op_str);
	} else {
		out = malloc(strlen(v1->str) + strlen(v2->str) + 21);
		sprintf(out, " %s %s %s ", v1->str, op_str, v2->str);
	}
	return out;
}

struct value * sum(struct value *v1, struct value *v2) {
	struct value * out = malloc(sizeof(struct value));
	
	if(v1->var_type == TYPE_UNDEF || v2->var_type == TYPE_UNDEF)
		yyerror("Attempt to use an undefined variable");
	if(v1->var_type == TYPE_NUMBER && v2->var_type == TYPE_NUMBER) {
		return operate(v1, v2, "+");
	} else {
		out->str = concat(v1->str, v2->str);
		out->var_type = TYPE_STRING;
		return out;
		//"1 + num1" SUM "\"hola\"" -> "strcat(itoa(1 + num1),\"hola\")"
	}
	return out;
}


struct value * sub(struct value *v1, struct value *v2) {
	if(v1->var_type == TYPE_NUMBER && v2->var_type == TYPE_NUMBER) {
		return operate(v1, v2, "-");
	} else {
		yyerror("Can't substract strings");
	}
}

struct value * mul(struct value *v1, struct value *v2) {
	if(v1->var_type == TYPE_NUMBER && v2->var_type == TYPE_NUMBER) {
		return operate(v1, v2, "*");
	} else {
		yyerror("Can't multiply strings");
	}
}

struct value * mod(struct value *v1, struct value *v2) {
	if(v1->var_type == TYPE_NUMBER && v2->var_type == TYPE_NUMBER) {
		return operate(v1, v2, "%");
	} else {
		yyerror("Can't modulo strings");
	}
}

struct value * divi(struct value *v1, struct value *v2) {
	/*if($3 == 0.0)
	yyerror("Attempt to divde by zero");
	else*/
	if(v1->var_type == TYPE_NUMBER && v2->var_type == TYPE_NUMBER) {
		return operate(v1, v2, "/");
	} else {
		yyerror("Can't divide strings");
	}
}

char * concat(char *str1, char *str2)
{
	char *concatStr = realloc(str1, strlen(str1) + strlen(str2) + 1);
	strcat(concatStr, str2);
	return concatStr;
}

struct value * operate(struct value *v1, struct value *v2, char *op) {
	struct value * out = malloc(sizeof(struct value));
	out->str = realloc(v1->str, strlen(v1->str) + strlen(v2->str) + strlen(op) + 1);
	strcat(out->str, op);
	strcat(out->str, v2->str);
	free(v2->str);
	free(v2);
	return out;
}

int lineno = 1;

#define DEFAULT_OUTFILE "out.c"

char *usage = "%s: usage [infile] [outfile]\n";


void main(int argc, char **argv)
{
	char *outfile;
	char *infile;
	extern FILE *yyin, *yyout;
    
	progname = argv[0];
    
	if(argc > 3)
	{
        	fprintf(stderr,usage, progname);
		exit(1);
	}
	if(argc > 1)
	{
		infile = argv[1];
		/* open for read */
		yyin = fopen(infile,"r");
		if(yyin == NULL) /* open failed */
		{
			fprintf(stderr,"%s: cannot open %s\n", 
				progname, infile);
			exit(1);
		}
	}

	if(argc > 2)
	{
		outfile = argv[2];
	}
	else
	{
      		outfile = DEFAULT_OUTFILE;
	}
    
	yyout = fopen(outfile,"w");
	if(yyout == NULL) /* open failed */
	{
      		fprintf(stderr,"%s: cannot open %s\n", 
                	progname, outfile);
		exit(1);
	}
    
	/* normal interaction on yyin and 
	   yyout from now on */
    fprintf(yyout, header);
	yyparse();
	fprintf(yyout, footer);
    
	/* now check EOF condition */
	if(!parsing_done) /* in the middle of a screen */
	{
        	warning("Premature EOF",(char *)0);
		unlink(outfile); /* remove bad file */
		exit(1);
	}
	exit(0); /* no error */
}

void warning(char *s, char *t) /* print warning message */
{
	fprintf(stderr, "%s: %s", progname, s);
	if (t)
		fprintf(stderr, " %s", t);
	fprintf(stderr, " line %d\n", lineno);
}

void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
 }

void symDeclare(char const *s)
{	
	struct symtab *sp;
	for(sp = symtab; sp < &symtab[NSYMS]; sp++) {
		if(sp->name && !strcmp(sp->name, s))
			 sp->isDeclared = 1;
	}
}
void symIsDeclared(char const *s)
{	
	struct symtab *sp;
	for(sp = symtab; sp < &symtab[NSYMS]; sp++) {
		if(sp->name && !strcmp(sp->name, s))
			if(sp->isDeclared)
				return;
	}
	yyerror("Variable is not declared");
	exit(1);
}

/* look up a symbol table entry, add if not present */
struct symtab *symlook(char const *s)
{
	char *p;
	struct symtab *sp;
	
	for(sp = symtab; sp < &symtab[NSYMS]; sp++) {
		/* is it already here? */
		if(sp->name && !strcmp(sp->name, s))
			return sp;
		
		/* is it free */
		if(!sp->name) {
			sp->name = strdup(s);
			sp->var_type = TYPE_UNDEF;
			return sp;
		}
		/* otherwise continue to next */
	}
	yyerror("Too many symbols");
	exit(1);	/* cannot continue */
} /* symlook */

