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

%union {
    long number;
    char character;
    char* string;
}

%type <string> IDENTIFIER STRING
%type <number> NUMBER 

%start program
%%
program: 
    global_list {
        root = (node_t *) malloc ( sizeof(node_t) );
        node_init ( root, PROGRAM, NULL, 1, $1 );
        $$ = root;
    }
;

global_list: 
    global {
        $$ = node_create(GLOBAL_LIST, NULL, 1, $1);
    }
    | global global_list{
        $$ = node_create(GLOBAL_LIST, NULL, 2, $1, $2);
    }
;

global: 
    function {
        $$ = node_create(GLOBAL_LIST, NULL, 1, $1);
    }
    | declaration {
        $$ = node_create(GLOBAL_LIST, NULL, 1, $1);
    }
;

statement_list:
    statement {
        $$ = node_create(STATEMENT_LIST, NULL, 1, $1);
    }
    | statement_list statement {
        $$ = node_create(STATEMENT_LIST, NULL, 2, $1, $2);
    }
;

print_list:
    print_item {
        $$ = node_create(PRINT_LIST, NULL, 1, $1);
    }
    | print_list ',' print_item {
        $$ = node_create(PRINT_LIST, NULL, 2, $1, $3);
    }
;

expression_list:
    expression {
        $$ = node_create(EXPRESSION_LIST, NULL, 1, $1);
    }
    | print_list ',' expression {
        $$ = node_create(EXPRESSION_LIST, NULL, 2, $1, $3);
    }
;

variable_list:
    identifier {
        $$ = node_create(VARIABLE_LIST, NULL, 1, $1);
    }
    | variable_list ',' identifier {
        $$ = node_create(VARIABLE_LIST, NULL, 2, $1, $3);
    }
;

argument_list:
    %empty {
        $$ = node_create(ARGUMENT_LIST, NULL, 0);
    }
    | expression_list {
        $$ = node_create(ARGUMENT_LIST, NULL, 1, $1);
    }
;

parameter_list:
    %empty {
        $$ = node_create(PARAMETER_LIST, NULL, 0);
    }
    | variable_list {
        $$ = node_create(PARAMETER_LIST, NULL, 1, $1);
    }
;

declaration_list:
    declaration {
        $$ = node_create(DECLARATION_LIST, NULL, 1, $1);
    }
    | declaration_list declaration {
        $$ = node_create(DECLARATION_LIST, NULL, 1, $1, $2);
    }

function            : FUNC IDENTIFIER '(' parameter_list ')' statement

statement           : assign_statement
                    | return_statement
                    | print_statement
                    | if_statement
                    | while_statement
                    | null_statement
                    | block

block               : OPENBLOCK declaration_list statement_list CLOSEBLOCK
                    | OPENBLOCK statement_list CLOSEBLOCK

assign_statement    : IDENTIFIER ASSIGNMENT expression

return_statement    : RETURN expression

print_statement     : PRINT print_list

null_statement      : CONTINUE

if_statement        : IF relation THEN statement
                    | IF relation THEN statement ELSE statement

while_statement     : WHILE relation DO statement

relation            : expression '=' expression
                    | expression '<' expression
                    | expression '>' expression

expression          : expression '|' expression
                    | expression '^' expression
                    | expression '&' expression
                    | expression LSHIFT expression
                    | expression RSHIFT expression
                    | expression '+' expression
                    | expression '-' expression
                    | expression '*' expression
                    | expression '/' expression
                    | '-' expression
                    | '~' expression
                    | '-' expression
                    | '(' expression ')'

declaration         : VAR variable_list

printitem           : expression
                    | string

identifier          : IDENTIFIER { }

number              : NUMBER {  }

string              : STRING {  }
%%

int
yyerror ( const char *error )
{
    fprintf ( stderr, "%s on line %d\n", error, yylineno );
    exit ( EXIT_FAILURE );
}
