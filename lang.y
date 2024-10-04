%{

#include "Table_des_symboles.h"

#include <stdio.h>
#include <stdlib.h>
  
extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
  exit(0);
}
		
int depth=0; // block depth
int label_count_if = 0;
int label_count_while = 0;
 
%}

%union { 
  struct ATTRIBUTE * symbol_value;
  char * string_value;
  int int_value;
  float float_value;
  int type_value;
  int label_value;
  int offset_value;
}

%token <int_value> NUM
%token <float_value> DEC


%token INT FLOAT VOID

%token <string_value> ID
%token AO AF PO PF PV VIR
%token RETURN  EQ
%token <label_value> IF ELSE WHILE

%token <label_value> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%nonassoc IFX
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%{

char * type2string (int c) {
  switch (c)
    {
    case INT:
      return("int");
    case FLOAT:
      return("float");
    case VOID:
      return("void");
    default:
      return("type error");
    }  
};

int checkType(int num1, int num2) {

    if ((num1 == INT) && (num2 == INT)) {
        return INT;
    } else {
        return FLOAT;
    }
};

void checkConvertion(int* num1, int* num2) {
  if (*num1 == INT) {
    *num1 = FLOAT;
    printf("I2F2 //converting first arg to float \n");
  }
  
  if (*num2 == INT) {
    *num2 = FLOAT;
    printf("I2F //converting second arg to float\n");
  }
}

int make_label_if(){
  int tmp = label_count_if;
  label_count_if ++;
  return tmp;
}

int make_label_while(){
  int tmp = label_count_while;
  label_count_while++;
  return tmp;
}

void printLoadedValue(sid s){
  attribute r = get_symbol_value(s);
  int diff = depth - r->depth;
  if(r->depth == 0) printf("LOADP(%d) /Loading %s value\n", r->offset, s);
  else if(diff == 0)   printf("LOADP(bp + %d) //Loading %s in curent block\n", r->offset, s);
  else {
    printf("LOADP(");
    for (int i = 0; i < diff; i++) {
      printf("stack[");
    }
    printf("bp");
    for (int i = 0; i < diff ; i++) {
      printf("]");
    }
    printf(" + %d)//Loading %s value %d block above\n",r->offset, s, diff-1);
  }
}

void printStoredValue(sid s){
  attribute r = get_symbol_value(s);
  int diff = depth - r->depth;
  if(r->depth == 0) printf("STOREP(%d) //storing %s value\n", r->offset, s);
  else if(diff==0){
    printf("STOREP(bp + %d)//storing %s value in current block\n",r->offset,s);
  }
  else {
    printf("STOREP(");
    for (int i = 0; i < diff; i++) {
      printf("stack[");
    }
    printf("bp");
    for (int i = 0; i < diff ; i++) {
      printf("]");
    }
    printf(" + %d)//storing %s value %d block above\n",r->offset, s, diff);
  }
}

void removeDepthVariable(int depth){
    sid *tab; 
    int array_size; 

    filter_symbols_by_depth(depth, &tab, &array_size);

  for (int i = 0; i < array_size; i++) {
    printf("// Removing variable %s at depth %d\n", (char *) tab[i], depth);
  }

  free(tab);
}

typedef struct {
    char* arg_name;
    int offset;
} ArgInfo;

ArgInfo arg_list[100];
int arg_count = 0;
%}


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <type_value> type exp typename
%type <string_value> fun_head fid
%type <type_value> ret aff   
%type <label_value> if while
%type <offset_value> decl_list glob_decl_list decl var_decl vlist inst block fun_body params fun app args arglist


 /* Attention, la rêgle de calcul par défaut $$=$1 
    peut créer des demandes/erreurs de type d'attribut */

%%

 // O. Déclaration globale

prog : glob_decl_list              {}

glob_decl_list : glob_decl_list fun {$$=$1;}
| glob_decl_list decl PV       {$$=$2;}
|                              {$$=0;} // empty glob_decl_list shall be forbidden, but usefull for offset computation

// I. Functions

fun : type fun_head fun_body   {}
;

fun_head : ID PO PF            {
  // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level~!\n");  
  printf("void pcode_%s(){\n",$1);
  $$=$1;
  }

| ID PO params PF              {
   // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level~!\n");
  printf("void pcode_%s(){\n",$1);
  for (int i = 0; i < arg_count; i++) {
    printf("//Argument %s of function %s in TDS with offset %d\n",
    arg_list[i].arg_name, $1, arg_list[i].offset);
  }
  arg_count = 0; 
  $$=$1;
 }
;

params: type ID vir params     {$$=$4-1;
                                attribute r = makeSymbol($1, $$, 1);
                                set_symbol_value($2,r);
                                arg_list[arg_count++] = (ArgInfo){$2, $$};
                                }
| type ID                      {$$=-1;
                                attribute r = makeSymbol($1, $$, 1);
                                set_symbol_value($2,r);
                                arg_list[arg_count++] = (ArgInfo){$2, $$};
                                }


vir : VIR                      {}
;

fun_body : fao block faf       {$$=0;
                                removeDepthVariable(1);
                                printf("// Exiting function block, removing loc var and arg from TDS\n}\n");}
;

fao : AO                       {printf("// entering function block\n");
                                depth++;}
;
faf : AF                       {depth--;
                                }
;


// II. Block
block:
decl_list inst_list            {$$=$1;}
;

// III. Declarations

decl_list : decl_list decl PV   {$$=$2;} 
|                               {$$=1;}
;

decl: var_decl                  {$$=$1;}
;

var_decl : type vlist          {$$=$2;}
;

vlist: vlist vir ID            {$$=$1; 
                                attribute r = makeSymbol($<type_value>0, $$, depth);
                                set_symbol_value($3,r);
                                if($<type_value>0 == INT) printf("//Declare %s of type int with offset %d at depth %d\nLOADI(0)\n\n",$3,r->offset,r->depth); 
                                else printf("//Declare %s of type int with offset %d at depth %d\nLOADF(0.0)\n\n",$3,r->offset,r->depth); 
                                $$=$1+1;
                                } // récursion gauche pour traiter les variables déclararées de gauche à droite
| ID                           {$$=$<offset_value>-1;
                                attribute r = makeSymbol($<type_value>0, $$, depth);
                                set_symbol_value($1,r);
                                if($<type_value>0 == INT) printf("//Declare %s of type int with offset %d at depth %d\nLOADI(0)\n\n",$1,r->offset,r->depth); 
                                else printf("//Declare %s of type int with offset %d at depth %d\nLOADF(0.0)\n\n",$1,r->offset,r->depth); 
                                $$=$<offset_value>-1 +1;
                                }
;

type
: typename                     {}
;

typename
: INT                          {$$=INT;}
| FLOAT                        {$$=FLOAT;}
| VOID                         {$$=VOID;}
;

// IV. Intructions

inst_list: inst_list inst   {} 
| inst                      {}
;

pv : PV                       {}
;
 
inst:
ao block af                   {$$=0;}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades explicites pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                       {depth++;
                              printf("SAVEBP//entering block\n");}
;

af : AF                       {removeDepthVariable(depth);
                              depth--;
                              printf("RESTOREBP//exiting block\n");}
;


// IV.1 Affectations

aff : ID EQ exp               {$$ = $3; 
                              printStoredValue(string_to_sid($1));}
;


// IV.2 Return
ret : RETURN exp              {$$ = $2; printf("return;\n");}
| RETURN PO PF                {}
;

// IV.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst  elsop       {}
;

elsop : else inst              {printf("End_%d:\n//Fin conditionelle %d\n", $<label_value>-2, $<label_value>-2);}
|                  %prec IFX   {} // juste un "truc" pour éviter le message de conflit shift / reduce
;

bool_cond : PO exp PF         {printf("IFN(False_%d)\n//la condition %d est vraie\n", $<label_value>0, $<label_value>0);}


if : IF                       {$$=make_label_if();}
;

else : ELSE                   {printf("GOTO(End_%d)\nFalse_%d:\n//la condition %d est fausse\n", $<label_value>-2 , $<label_value>-2,$<label_value>-2);}

;

// IV.4. Iterations

loop : while while_cond inst  {printf("GOTO(StartLoop_%d)\nEndLoop_%d\n",$1, $1);}
;

while_cond : PO exp PF        {printf("IFN(EndLoop_%d)\n", $<label_value>0);}

while : WHILE                 {$$=make_label_while();printf("StartLoop_%d\n", $$);}
;


// V. Expressions

exp
// V.1 Exp. arithmetiques
: MOINS exp %prec UNA         {}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {$$=checkType($1,$3);
                                if ($$ == INT) printf("ADDI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("ADDF\n");
                                  };
                                }
| exp MOINS exp               {$$=checkType($1,$3);
                                if ($$ == INT) printf("SUBI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("SUBF\n");
                                  }
                                }
| exp STAR exp                {$$=checkType($1,$3);
                                if ($$ == INT) printf("MULTI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("MULTF\n");
                                  }
                                }
| exp DIV exp                 {$$=checkType($1,$3);
                                if ($$ == INT) printf("DIVI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("DIVF\n");
                                  }
                                }
| PO exp PF                   {}
| ID                         {attribute a = get_symbol_value(string_to_sid($1));
                              printLoadedValue(string_to_sid($1));
                              if (a->type == INT) $$ = INT;
                              else $$ = FLOAT;}
| app                         {}
| NUM                         {$$ = INT;
                                printf("LOADI(%d)\n", $1);}
| DEC                         {$$ = FLOAT;
                                printf("LOADF(%f)\n", $1);}

// V.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 {$$=checkType($1,$3);
                                if ($$ == INT) printf("LTI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("LTF\n");
                                  }
                              }
| exp SUP exp                 {$$=checkType($1,$3);
                                if ($$ == INT) printf("GTI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("GTF\n");
                                  }
                              }
| exp EQUAL exp               {$$=checkType($1,$3);
                                if ($$ == INT) printf("EQI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("EQF\n");
                                  }
                              }
| exp DIFF exp                {$$=checkType($1,$3);
                                if ($$ == INT) printf("NEQI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("NEQF\n");
                                  }
                              }
| exp AND exp                 {$$=checkType($1,$3);
                                if ($$ == INT) printf("ANDI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("ANDF\n");
                                  }
                              }
| exp OR exp                  {$$=checkType($1,$3);
                                if ($$ == INT) printf("ORI\n");
                                else {
                                  checkConvertion(&$1,&$3);
                                  printf("ORF\n");
                                  }
                              }

;

// V.3 Applications de fonctions


app : fid PO args PF          {printf("SAVEBP\nCALL(pcode_%s)\nRESTOREBP\nENDCALL(%d) // unloading %d args of function plusUn\n",$1, $3,$3);}
;

fid : ID                      {$$=$1;
                              printf("// loading function %s arguments\n",$1);
                              }

args :  arglist               {$$=$1;}
|                             {$$=0;}
;

arglist : arglist VIR exp     {$$=$1 +1;} // récursion gauche pour empiler les arguements de la fonction de gauche à droite
| exp                         {$$=1;}
;



%% 
int main () {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

char * header=
"// PCode Header\n\
#include \"PCode.h\"\n\
\n\
int main() {\n\
pcode_main();\n\
return stack[sp-1].int_value;\n\
}\n";  

 printf("%s\n",header); // ouput header
  
return yyparse ();
 
 
} 

