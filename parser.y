%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
    
int parsing_done = 1; 
int yydebug = 1;

void warning(char *s, char *t);
void yyerror (char const *s);
FILE *yyout;
%}

%union {
    char    *string;     /* string buffer */
    double    number;          /* command value */
}

%token <string> STRING ID
%token <number> NUMBER 
%token <cmd> OPEN_LOOP CLOSE_LOOP SUM SUB MUL DIV VAR
%token <cmd> ASSIGN END GREATER LESSER END_LINE 
%type <number> statement

%start file

%%

file: 	  file statement
		| statement
		;

statement:    VAR ID ASSIGN STRING END_LINE { fprintf(yyout, "char* %s = \"%s\";\n", $2, $4); }
            | VAR ID ASSIGN NUMBER END_LINE { fprintf(yyout, "double %s = %f;\n", $2, $4); }
            | ID ASSIGN STRING END_LINE { fprintf(yyout, "%s = \"%s\";\n", $1, $3); }
            | ID ASSIGN NUMBER END_LINE { fprintf(yyout, "%s = %f;\n", $1, $3); }


NUMBER:    NUMBER SUM NUMBER { $$ = $1 + $3; }
            | NUMBER SUB NUMBER { $$ = $1 + $3; }
            | NUMBER MUL NUMBER { $$ = $1 * $3; }
            | NUMBER DIV NUMBER {
                                        if($3 == 0.0)
                                            yyerror("Attempt to divde by zero");
                                        else
                                            $$ = $1 / $3;
                                     }
            | NUMBER
            ;
%%

char *progname = "mgl";
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
    
	yyparse();
    
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
