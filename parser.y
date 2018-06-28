%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.h"

#define FLOAT_DEC_PTS "%.10f"
    
int parsing_done = 1; 
int yydebug = 1;

void warning(char *s, char *t);
void yyerror (char const *s);
void symIsDeclared(char const *s);
void symDeclare(char const *s);
FILE *yyout;
%}

%union {
    char    *string;     /* string buffer */
    double    number;          /* command value */
	struct symtab *symp
}

%token <string> STRING 
%token <symp> ID
%token <number> NUMBER 
%token <cmd> OPEN_LOOP CLOSE_LOOP SUM SUB MUL DIV VAR
%token <cmd> ASSIGN GREATER LESSER IF END_LINE 
%type <number> operation statement
%type <variable> value

%start statements

%%

statements: 			statements statement
					| 	statement
					;



statement:   
			  VAR ID END_LINE
			| VAR ID ASSIGN value END_LINE 
            | ID ASSIGN value END_LINE 
			| PRINT value END_LINE
			| IF condition THEN statements END_IF
			| IF condition THEN statements ELSE statements END_IF
			| WHILE condition DO statements END_WHILE
			;

value: 	  STRING
		| NUMBER
		| operation
		| ID
		;

		
condition: 	  NOT condition 
			| PARENTHESIS_OPENED condition logic_op condition PARENTHESIS_CLOSED
			| bool_exp
			;

bool_exp: value comparation value 		{$$->str = writeBool($1, $2->operand, $3); };

comparation:  GREATER 		{ $$->operand = GREATER }
			| LESSER  		{ $$->operand = LESSER }
			| LESSER_EQ 	{ $$->operand = LESSER_EQ }
			| GREATER_EQ 	{ $$->operand = GREATER_EQ }
			| EQUALS 		{ $$->operand = EQUALS }
			| NOT_EQUALS	{ $$->operand = NOT_EQUALS }
			;

logic_op: 	  AND		{ $$->str = "&&" } 
			| OR 		{ $$->str = "||" }
			;

operation:    value SUM value { $$ = $1 + $3; }
            | value SUB value { $$ = $1 + $3; }
            | value MUL value { $$ = $1 * $3; }
            | value DIV value {
                                        if($3 == 0.0)
                                            yyerror("Attempt to divde by zero");
                                        else
                                            $$ = $1 / $3;
                                     }
            | value MOD value { }
            ;
%%

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
    fprintf(yyout, "int asd(){\n");
	yyparse();
	fprintf(yyout, "\n}");
    
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
			return sp;
		}
		/* otherwise continue to next */
	}
	yyerror("Too many symbols");
	exit(1);	/* cannot continue */
} /* symlook */

