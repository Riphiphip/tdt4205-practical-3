%{
#include <vslc.h>
%}
%left '|'
%left '^'
%left '&'
%left LSHIFT RSHIFT
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '~'
//%expect 1

%token FUNC PRINT RETURN CONTINUE IF THEN ELSE WHILE DO OPENBLOCK CLOSEBLOCK
%token VAR NUMBER IDENTIFIER STRING LSHIFT RSHIFT ASSIGNMENT

%start program
%%
program :
  global_list {
    root = (node_t *) malloc ( sizeof(node_t) );
    node_init ( root, PROGRAM, NULL, 1, $1 );
    $$ = root;
  }
  ;
global_list : 
  global
      | global global_list
    ;
%%

int
yyerror ( const char *error )
{
    fprintf ( stderr, "%s on line %d\n", error, yylineno );
    exit ( EXIT_FAILURE );
}
