%{
#include <vslc.h>

node_t* relation_node(node_t* exp1, node_t* exp2, char* optype)
{
    char* node_data = strdup(optype);
    return node_create(RELATION, node_data, 2, exp1, exp2);
}

node_t* binop_node(node_t* exp1, node_t* exp2, char* optype) {
    char* node_data = strdup(optype);
    return node_create(EXPRESSION, node_data, 2, exp1, exp2); 
}

node_t* unop_node(node_t* exp1, char* optype) {
    char* node_data = strdup(optype);
    return node_create(EXPRESSION, node_data, 1, exp1); 
}
%}
%left '|'
%left '^'
%left '&'
%left LSHIFT RSHIFT
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '~'
%nonassoc IF THEN
%nonassoc ELSE
//%expect 1

%token FUNC PRINT RETURN CONTINUE IF THEN ELSE WHILE DO OPENBLOCK CLOSEBLOCK
%token VAR NUMBER IDENTIFIER STRING LSHIFT RSHIFT ASSIGNMENT UMINUS

%union {
    long number;
    char character;
    char* string;
    node_t* node;
}

%type <node> program global_list global statement_list print_list expression_list
%type <node> variable_list argument_list parameter_list declaration_list function statement block
%type <node> assign_statement return_statement print_statement null_statement if_statement while_statement
%type <node> relation expression declaration print_item identifier number string
%type <string> IDENTIFIER STRING 
%type <number> NUMBER
%start program
%%
program
    : global_list { root = node_create(PROGRAM, NULL, 1, $1); $$ = root; }
    ;

global_list
    : global                { $$ = node_create(GLOBAL_LIST, NULL, 1, $1); }
    | global global_list    { $$ = node_create(GLOBAL_LIST, NULL, 2, $1, $2); }
    ;

global 
    : function      { $$ = node_create(GLOBAL, NULL, 1, $1); }
    | declaration   { $$ = node_create(GLOBAL, NULL, 1, $1); }
    ;

statement_list
    : statement                 { $$ = node_create(STATEMENT_LIST, NULL, 1, $1); }
    | statement_list statement  { $$ = node_create(STATEMENT_LIST, NULL, 2, $1, $2); }
    ;

print_list
    : print_item                { $$ = node_create(PRINT_LIST, NULL, 1, $1); }
    | print_list ',' print_item { $$ = node_create(PRINT_LIST, NULL, 2, $1, $3); }
    ;

expression_list
    : expression                { $$ = node_create(EXPRESSION_LIST, NULL, 1, $1); }
    | print_list ',' expression { $$ = node_create(EXPRESSION_LIST, NULL, 2, $1, $3); }
    ;

variable_list
    : identifier                    { $$ = node_create(VARIABLE_LIST, NULL, 1, $1); }
    | variable_list ',' identifier  { $$ = node_create(VARIABLE_LIST, NULL, 2, $1, $3); }
    ;

argument_list
    : %empty            { $$ = node_create(ARGUMENT_LIST, NULL, 0); }
    | expression_list   { $$ = node_create(ARGUMENT_LIST, NULL, 1, $1); }
    ;

parameter_list
    : %empty        { $$ = node_create(PARAMETER_LIST, NULL, 0); }
    | variable_list { $$ = node_create(PARAMETER_LIST, NULL, 1, $1); }
    ;

declaration_list
    : declaration                   { $$ = node_create(DECLARATION_LIST, NULL, 1, $1); }
    | declaration_list declaration  { $$ = node_create(DECLARATION_LIST, NULL, 1, $1, $2); }
    ;

function
    : FUNC identifier '(' parameter_list ')' statement { $$ = node_create(FUNCTION, NULL, 3, $2, $4, $6); }
    ;

statement
    : assign_statement  { $$ = node_create(STATEMENT, NULL, 1, $1); }
    | return_statement  { $$ = node_create(STATEMENT, NULL, 1, $1); }
    | print_statement   { $$ = node_create(STATEMENT, NULL, 1, $1); }
    | if_statement      { $$ = node_create(STATEMENT, NULL, 1, $1); }
    | while_statement   { $$ = node_create(STATEMENT, NULL, 1, $1); }
    | null_statement    { $$ = node_create(STATEMENT, NULL, 1, $1); }
    | block             { $$ = node_create(STATEMENT, NULL, 1, $1); }
    ;

block
    : OPENBLOCK declaration_list statement_list CLOSEBLOCK  { $$ = node_create(BLOCK, NULL, 2, $2, $3); }
    | OPENBLOCK statement_list CLOSEBLOCK                   { $$ = node_create(BLOCK, NULL, 1, $2);  }
    ;

assign_statement
    :  identifier ASSIGNMENT expression { $$ = node_create(ASSIGNMENT_STATEMENT, NULL, 2, $1, $3); } 
    ;

return_statement
    : RETURN expression { $$ = node_create(RETURN_STATEMENT, NULL, 1, $2); }
    ;

print_statement
    : PRINT print_list { $$ = node_create(PRINT_STATEMENT, NULL, 1, $2); }
    ;

null_statement
    : CONTINUE { $$ = node_create(NULL_STATEMENT, NULL, 0); }
    ;

if_statement
    : IF relation THEN statement                { $$ = node_create(IF_STATEMENT, NULL, 2, $2, $4); }
    | IF relation THEN statement ELSE statement { $$ = node_create(IF_STATEMENT, NULL, 3, $2, $4, $6); }
;

while_statement
    : WHILE relation DO statement { $$ = node_create(WHILE_STATEMENT, NULL, 2, $2, $4); }
    ;

relation
    :  expression '=' expression   { $$ = relation_node($1, $3, "="); }
    | expression '<' expression     { $$ = relation_node($1, $3, "<"); }
    | expression '>' expression     { $$ = relation_node($1, $3, ">"); }
    ;

expression 
    : expression '|' expression         { $$ = binop_node($1, $3, "|");  }
    | expression '^' expression         { $$ = binop_node($1, $3, "^");  }
    | expression '&' expression         { $$ = binop_node($1, $3, "&");  }
    | expression LSHIFT expression      { $$ = binop_node($1, $3, "<<"); }
    | expression RSHIFT expression      { $$ = binop_node($1, $3, ">>"); }
    | expression '+' expression         { $$ = binop_node($1, $3, "+");  }
    | expression '-' expression         { $$ = binop_node($1, $3, "-");  }
    | expression '*' expression         { $$ = binop_node($1, $3, "*");  }
    | expression '/' expression         { $$ = binop_node($1, $3, "/");  }
    | UMINUS expression                 { $$ = unop_node($2, "-"); }
    | '~' expression                    { $$ = unop_node($2, "~"); }
    | '(' expression ')'                { $$ = $2; }
    | number                            { $$ = node_create(EXPRESSION, NULL, 1, $1); }
    | identifier                        { $$ = node_create(EXPRESSION, NULL, 1, $1); }
    | identifier '(' argument_list ')'  { $$ = node_create(EXPRESSION, NULL, 2, $1, $3); }
    ;

declaration
    : VAR variable_list { $$ = node_create(DECLARATION, NULL, 1, $2); }
    ;

print_item
    : expression { $$ = node_create(PRINT_ITEM, NULL, 1, $1); }
    | string { $$ = node_create(PRINT_ITEM, NULL, 1, $1); }
    ;

identifier
    : IDENTIFIER { char* node_data = strdup($1); $$ = node_create(IDENTIFIER_DATA, node_data, 0); }
    ;

number
    : NUMBER { long* node_data = malloc(sizeof(long)); *node_data = $1; $$ = node_create(NUMBER_DATA, node_data, 0); }
    ;

string
    : STRING { char* node_data = strdup($1); $$ = node_create(STRING_DATA, node_data, 0); }
    ;
%%

int yyerror (const char *error)
{
    fprintf (stderr, "%s on line %d\n near '%s'\n", error, yylineno, yytext);
    exit (EXIT_FAILURE);
}
