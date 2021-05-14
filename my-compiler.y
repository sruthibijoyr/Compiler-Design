%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include<string.h>
	void yyerror(char *str);
	int yylex(void);

	struct info 
	{
		char var[10];
		char code[100];
		char opt[100];
    char gen[100]
	};

	void makeTemp(int count, char *var)
	{
		sprintf(var,"t%d",count);
	}

	struct info* makeNode(int count) 
	{
		struct info *temp;
		temp = malloc(sizeof(struct info));

		makeTemp(count, temp->var);

		strcpy(temp->code, "");
		strcpy(temp->opt, ""); 
    strcpy(temp->gen, ""); 
		return temp;
	}

	char code[500],opt[500], gen[500]; 
  char R[3][10];
	int temp_count=0;
  int reg,reg1,reg2;

  int findReg(char *var){
    int i;
    for(i=0;i<3;++i){
      if(!(strcmp(R[i],""))){
        return i;
      }
      else if(!(strcmp(R[i],var))){
        return i;
      }
    }
    return 0;
  }
	
%}

%union {
	struct info *node;
	char name[50];
}

%token <name> ID CONST
%type <node> A T F E
%left '*' '/'
%right '+' '-'

%%

S : B S
  | /* epsilon */ {printf("\n\nSyntactically correct\n\nGenerated TAC:\n%s\n\nOptimised Code:\n%s\n\nGenerated Code:\n%s",code,opt,gen); return 1;}
; 

B : A {strcat(code,$1->code); strcat(opt,$1->opt); strcat(gen,$1->gen);}

A : ID'='E{
			$$ = makeNode(0);
			sprintf($$->code, "%s%s = %s\n", $3->code, $1, $3->var);
			sprintf($$->opt, "%s%s = %s\n", $3->opt, $1, $3->var);
      reg = findReg($3->var);
      sprintf($$->gen, "%sMOV %s, R%d\n", $3->gen, $1, reg);
		}

E : E'*'T{
			$$ = makeNode(temp_count); 
		  	temp_count++; 
		  	sprintf($$->code, "%s%s%s = %s * %s\n", $1->code, $3->code, $$->var, $1->var, $3->var);
		  	if(!strcmp($1->var,"1")){
  				sprintf($$->opt, "%s%s%s = %s\n", $1->opt, $3->opt, $$->var, $3->var);
  			}
  			else if(!strcmp($3->var,"1")){
  				sprintf($$->opt, "%s%s%s = %s\n", $1->opt, $3->opt, $$->var, $1->var);
  			}
  			else if(!strcmp($3->var,"0")){
  				sprintf($$->opt, "%s%s%s = 0\n", $1->opt, $3->opt, $$->var);
  			}
  			else if(!strcmp($3->var,"2")){
  				sprintf($$->opt, "%s%s%s = %s + %s\n", $1->opt, $3->opt, $$->var, $1->var, $1->var);
  			}
  			else if(!strcmp($1->var,"2")){
  				sprintf($$->opt, "%s%s%s = %s + %s\n", $1->opt, $3->opt, $$->var, $3->var, $3->var);
  			}
  			else{
  				strcpy($$->opt,$$->code);
  			}
        reg1 = findReg($1->var);
        reg2 = findReg($3->var);
        strcpy(R[reg1],$$->var);
        sprintf($$->gen, "%s%sMUL R%d, R%d\n", $1->gen, $3->gen, reg1, reg2);
  		}

  | E'/'T{
  			$$ = makeNode(temp_count); 
		  	temp_count++; 
		  	sprintf($$->code, "%s%s%s = %s / %s\n", $1->code, $3->code, $$->var, $1->var, $3->var);
		  	
		  	if(!strcmp($1->var,"0")){
  				sprintf($$->opt, "%s%s%s = 0\n", $1->opt, $3->opt, $$->var);
  			}
  			else if(!strcmp($3->var,"1")){
  				sprintf($$->opt, "%s%s%s = %s\n", $1->opt, $3->opt, $$->var, $1->var);
  			}
  			else{
  				strcpy($$->opt,$$->code);
  			}
        reg1 = findReg($1->var);
        reg2 = findReg($3->var);
        strcpy(R[reg1],$$->var);
        sprintf($$->gen, "%s%sDIV R%d, R%d\n", $1->gen, $3->gen, reg1, reg2);

  		}

  | T {$$ = $1;}

T : F'+'T{
			$$ = makeNode(temp_count); 
			temp_count++; 
			sprintf($$->code, "%s%s%s = %s + %s\n", $3->code, $1->code, $$->var, $1->var, $3->var);
			
			if(!strcmp($1->var,"0")){
  				sprintf($$->opt, "%s%s%s = %s\n", $3->opt, $1->opt, $$->var, $3->var);
  			}
			else if(!strcmp($3->var,"0")){
				sprintf($$->opt, "%s%s%s = %s\n", $3->opt, $1->opt, $$->var, $1->var);
			}
			else{
				strcpy($$->opt,$$->code);
			}
      reg1 = findReg($1->var);
      reg2 = findReg($3->var);
      strcpy(R[reg1],$$->var);
      sprintf($$->gen, "%s%sADD R%d, R%d\n", $1->gen, $3->gen, reg1, reg2);
		}

  | F'-'T{
  			$$ = makeNode(temp_count); 
  			temp_count++; 
  			sprintf($$->code, "%s%s%s = %s - %s\n", $3->code, $1->code, $$->var, $1->var, $3->var);
  			
  			if(!strcmp($1->var,"0")){
  				sprintf($$->opt, "%s%s%s = -%s\n", $3->opt, $1->opt, $$->var, $3->var);
  			}
  			else if(!strcmp($3->var,"0")){
  				sprintf($$->opt, "%s%s%s = %s\n", $3->opt, $1->opt, $$->var, $1->var);
  			}
  			else{
  				strcpy($$->opt,$$->code);
  			}
        reg1 = findReg($1->var);
        reg2 = findReg($3->var);
        strcpy(R[reg1],$$->var);
        sprintf($$->gen, "%s%sSUB R%d, R%d\n", $1->gen, $3->gen, reg1, reg2);
  		}

  | F {$$ = $1;
      reg = findReg($1->var);
  }

F : ID {$$ = makeNode(0); strcpy($$->var, $1);
  reg = findReg($$->var);
  strcpy(R[reg],$$->var);
  sprintf($$->gen, "MOV R%d, %s\n", reg, $$->var);
}
| CONST {$$ = makeNode(0); strcpy($$->var, $1);
  reg = findReg($$->var);
  strcpy(R[reg],$$->var);
  sprintf($$->gen, "MOV R%d, %s\n", reg, $$->var);
}
  ;

%%

void yyerror(char *str)
{
	printf("%s",str);
}

int main()
{
  strcpy(R[0],"");
  strcpy(R[1],"");
  strcpy(R[2],"");

	printf("\n\n----------------------------INTERMEDIATE CODE GENERATION----------------------------\n");

	FILE *fp = fopen("input.txt", "r");
	char c = fgetc(fp);
    while (c != EOF)
    {
        printf ("%c", c);
        c = fgetc(fp);
    }
    fclose(fp);

	printf("\n\n----------------------------GENERATED CODE----------------------------\n");

	yyparse();
	printf("\n");
	return 0;
}