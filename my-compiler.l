%{ 
	#include <stdio.h>
	#include "y.tab.h"
	#include<string.h>
	extern YYSTYPE yylval;
	int yylex(void);
	void yyerror(char *str);
%}

ID [a-zA-Z][a-zA-Z0-9]*
CONST [0-9]+

%%

{ID} {strcpy(yylval.name, yytext); return ID;}
{CONST} {strcpy(yylval.name, yytext); return CONST;}
[' '] { };
['\t'] { };
['\n'] { };
. return yytext[0];

%%

int yywrap(){
	return 1;
}