%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "util.h"
#include "zf2182.calc.tab.h"

/* Used for variable stores. Defined in mem.h */
extern double variable_values[10];
extern int variable_set[10];
int set_variable(int index, double val);
/* Flex functions */
extern int yylex(void);
extern void yyterminate();
void yyerror(const char *s);
extern FILE* yyin;
%}

/* Bison declarations */


%union {
	int index;
	double num;
}

%token<num> NUMBER
%token<num> L_BRACKET R_BRACKET
%token<num> DIV MUL ADD SUB EQUALS
%token<num> PI
%token<num> POW SQRT FACTORIAL MOD
%token<num> LOG2 LOG10
%token<num> FLOOR CEIL ABS
%token<num> GBP_TO_USD USD_TO_GBP 
%token<num> GBP_TO_EURO EURO_TO_GBP 
%token<num> USD_TO_EURO EURO_TO_USD
%token<num> COS SIN TAN COSH SINH TANH
%token<num> CEL_TO_FAH FAH_TO_CEL
%token<num> MI_TO_KM KM_TO_MI
%token<num> VAR_KEYWORD 
%token<index> VARIABLE
%token<num> EOL
%token<num> EXT
%type<num> program_input
%type<num> line
%type<num> calculation
%type<num> constant
%type<num> expr
%type<num> function
%type<num> log_function
%type<num> trig_function
%type<num> assignment
%type<num> conversion
%type<num> temperature_conversion
%type<num> distance_conversion

/* Set operator precedence, follows BODMAS rules. */
%left SUB 
%left ADD
%left MUL 
%left DIV 
%left POW SQRT 
%left L_BRACKET R_BRACKET

%%
program_input:
	| program_input line
	;
	
line: 
			EOL 			{ printf("Please enter a calculation:\n"); }
		| calculation EOL  	{ printf("=%.2f\n",$1); }
		|	EXT				{printf(">> Bye!\n"); exit(0);}
    ;

calculation:
		  expr
		| function
		| assignment
		;
		
constant: PI { $$ = 3.14; }
		;
		
expr:
	SUB expr			{ $$ = -$2; }
    | NUMBER            { $$ = $1; }
	| VARIABLE			{ $$ = variable_values[$1]; }
	| constant	
	| function
	| expr DIV expr     { if ($3 == 0) { yyerror("Cannot divide by zero"); exit(1); } else $$ = $1 / $3; }
	| expr MUL expr     { $$ = $1 * $3; }
	| L_BRACKET expr R_BRACKET  { $$ = $2; }
	| expr ADD expr     { $$ = $1 + $3; }
	| expr SUB expr   	{ $$ = $1 - $3; }
	| expr POW expr     { $$ = pow($1, $3); }
	| expr MOD expr     { $$ = modulo($1, $3); }
    ;
		
function: 
		  conversion
		| log_function
		| trig_function
		| SQRT expr      		{ $$ = sqrt($2); }
		| expr FACTORIAL		{ $$ = factorial($1); }
		| ABS expr 				{ $$ = abs($2); }
		| FLOOR expr 			{ $$ = floor($2); }
		| CEIL expr 			{ $$ = ceil($2); }
		;

trig_function:
		 COS expr  				{ $$ = cos($2); }
		| SIN expr 				{ $$ = sin($2); }
		| TAN expr 				{ $$ = tan($2); }
		;
	
log_function:
		 LOG2 expr 				{ $$ = log2($2); }
		| LOG10 expr 			{ $$ = log10($2); }
		;
		
conversion:
		temperature_conversion
		| distance_conversion
		| expr GBP_TO_USD   { $$ = gbp_to_usd($1); }
		| expr USD_TO_GBP   { $$ = usd_to_gbp($1); }
		| expr GBP_TO_EURO  { $$ = gbp_to_euro($1); }
		| expr EURO_TO_GBP  { $$ = euro_to_gbp($1); }
		| expr USD_TO_EURO  { $$ = usd_to_euro($1); }
		| expr EURO_TO_USD  { $$ = euro_to_usd($1); }
		;

temperature_conversion:
		  expr CEL_TO_FAH 	{ $$ = cel_to_fah($1); }
		| expr FAH_TO_CEL 	{ $$ = fah_to_cel($1); }

distance_conversion:
		  expr MI_TO_KM 			{ $$ = mi_to_km($1); }
		| expr KM_TO_MI 			{ $$ = km_to_mi($1); }
		
assignment: 
		VAR_KEYWORD VARIABLE EQUALS calculation { $$ = set_variable($2, $4); }
		;
%%


int main(int argc, char** argv)
{	
	char c[2];
	printf("Command line or input file?(Enter F or f for read in file, enter else for command line):\n");
	scanf("%s", c);
	//c = (char*)"p";
	if (strcmp(c, "f")==0 || strcmp(c, "F")==0) {
		printf("Start reading zf2182.input.txt:\n");
		yyin = fopen("zf2182.input.txt", "r");
		if (!yyin) {
			printf("ERROR: Couldn't open file zf2182.input.txt\n");
			exit(-1);
		}
		yyparse();
		
		printf("All done with zf2182.input.txt");
	}
	else{
		// Command line
		printf("Here is Commond Line, please enter calculation :\n");
		yyin = stdin;
		yyparse();
	}
}
void yyerror(const char *s)
{
	printf("ERROR: %s Undefined symbol\n", s);
}

/* Set a variables value in the memory store */
int set_variable(int index, double val)
{
	variable_values[index] = val;
	variable_set[index] = 1;
	
	return val;
}
